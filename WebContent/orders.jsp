<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, javax.sql.*, javax.naming.*"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.6/css/bootstrap.min.css" integrity="sha384-1q8mTJOASx8j1Au+a5WDVnPi2lkFfwwEAa8hDDdjZlpLegxhjVME1fgjWPGmkzs7" crossorigin="anonymous">
<title>CSE135 Project</title>
</head>
<%
	Connection conn = null;
	try {
		Class.forName("org.postgresql.Driver");
		String url = "jdbc:postgresql:Junhao";
	    String admin = "postgres";
	    String password = "4258483";
    	conn = DriverManager.getConnection(url, admin, password);
	}
	catch (Exception e) {}
	
	String rows = request.getParameter("rows");
	String order = request.getParameter("order");
	String orderString = " ORDER BY name ";
	String filter = request.getParameter("filter");
	String filterString = "All";
	String rowNext = request.getParameter("rowNext");
	String colNext = request.getParameter("colNext");
	
	if (rows == null)
		session.setAttribute("rows", "Customers");
	else 
		session.setAttribute("rows", rows);
	
	if (order == null)
		session.setAttribute("order", "Alphabetical");
	else {
		session.setAttribute("order", order);
		if (order.equals("Top-K"))
			orderString = " ORDER BY totalsales DESC ";
		else
			orderString = " ORDER BY name ";
	}
	
	if (filter == null || filter.equals("All"))
		session.setAttribute("filter", "All");
	else {
		filterString = filter;
		Statement stmt = conn.createStatement();
		ResultSet rs = stmt.executeQuery("SELECT name FROM categories WHERE id = " + filter);
		if (rs.next())
			session.setAttribute("filter", rs.getString("name"));
	}
	
	if (session.getAttribute("run") == null)
		session.setAttribute("run", "not");
	
	if (session.getAttribute("allowedToEdit") == null)
		session.setAttribute("allowedToEdit", "yes");
	
	if (rowNext == null) 
		session.setAttribute("rowNum", 0);
	
	else if (rowNext.equals("clicked")) {
		session.setAttribute("rowNum", (Integer)session.getAttribute("rowNum") + 20);
		session.setAttribute("allowedToEdit", "no");
	}
	
	if (colNext == null) 
		session.setAttribute("colNum", 0);
	
	else if (colNext.equals("clicked")) {
		session.setAttribute("colNum", (Integer)session.getAttribute("colNum") + 10);
		session.setAttribute("allowedToEdit", "no");
	}
	
	Statement stmtP = conn.createStatement();
	ResultSet rsP = stmtP.executeQuery("SELECT name, COUNT(*) as num FROM products GROUP BY name");
	if (rsP.next()) 
		session.setAttribute("productNum", rsP.getInt("num"));
	
	Statement stmtC = conn.createStatement();
	ResultSet rsC = stmtC.executeQuery("SELECT name, COUNT(*) as num FROM users GROUP BY name");
	if (rsC.next()) 
		session.setAttribute("customerNum", rsC.getInt("num"));
	
	if ("POST".equalsIgnoreCase(request.getMethod())) {
		String action = request.getParameter("action");
		if (action != null && action.equals("runQuery")) {
			session.setAttribute("run", action);
		}
	}
	
	
	
%>

<body>
<div class="collapse navbar-collapse">
	<ul class="nav navbar-nav">
		<li><a href="index.jsp">Home</a></li>
		<li><a href="categories.jsp">Categories</a></li>
		<li><a href="products.jsp">Products</a></li>
		<li><a href="orders.jsp">Orders</a></li>
		<li><a href="login.jsp">Logout</a></li>
	</ul>
</div>
<div>

<% if (((String)session.getAttribute("allowedToEdit")).equals("yes")) { 
	Statement stmt1 = conn.createStatement();
	ResultSet rs1 = stmt1.executeQuery("SELECT id, name FROM categories");
%>
<div>
<form action="orders.jsp" method="POST">
	<input type="hidden" name="action" value="runQuery"/>
  	<label for="Rows">Rows:</label>
  	<select name="rows" id="rows" class="form-control">
	    <option value="Customers">Customers</option>
	    <option value="States">States</option>
	</select>	
  	<label for="Order">Order:</label>
  	<select name="order" id="order" class="form-control">
	    <option value="Alphabetical">Alphabetical</option>
	    <option value="Top-K">Top-K</option>
	</select>
	<label for="Filter">Sales Filtering Option:</label>
  	<select name="filter" id="filter" class="form-control">
  	<option value="<%=session.getAttribute("filter") %>"><%=session.getAttribute("filter") %></option>
  	<% while (rs1.next()) {  %>
  		<option value="<%=rs1.getString("id")%>"><%=rs1.getString("name")%></option>
  	<% } %>
		<option value="All">All</option>
	</select>
	<input class="btn btn-primary" type="submit" value="Run Query"/>
</form>
</div>
<% } %>
<% if (((String)session.getAttribute("run")).equals("runQuery")) { 
	
	Statement stmt2 = conn.createStatement();
	ResultSet rs2;
	
	if (filterString.equals("All")) {
		rs2 = stmt2.executeQuery("WITH col_header(product_id, totalsales) AS (SELECT product_id, SUM(orders.price) "
				+ "AS totalsales FROM orders GROUP BY product_id) SELECT products.name AS name, col_header.totalsales "
				+ "AS totalsales FROM products INNER JOIN col_header ON products.id = col_header.product_id "
				+ orderString + "LIMIT 10");
	}
	else {
		rs2 = stmt2.executeQuery("WITH col_header(product_id, totalsales) AS (SELECT product_id, SUM(orders.price) "
				+ "AS totalsales FROM products INNER JOIN orders on orders.product_id = products.id WHERE "
				+ "products.category_id = " + filterString + " GROUP BY product_id) SELECT products.name AS name, "
				+ "col_header.totalsales AS totalsales FROM products INNER JOIN col_header ON products.id = col_header.product_id"
				+ orderString + "LIMIT 10");
	} %>
<table class="table table-striped">
	<th></th>
	<% while (rs2.next()) { %>
		<th><%=rs2.getString("name")%> (<%=rs2.getFloat("totalsales") %>)</th>	
	<% }
	
	Statement stmt3 = conn.createStatement();
	ResultSet rs3;
	
	if (filterString.equals("All")) {
		rs3 = stmt3.executeQuery("WITH row_header(id, name, totalsales) AS (SELECT users.id AS id, users.name AS name, "
				+ "SUM(orders.price) AS totalsales FROM users INNER JOIN orders on users.id = orders.user_id "
				+ "GROUP BY users.id) SELECT DISTINCT LEFT(users.name, 10) AS name, users.id AS id, row_header.totalsales AS totalsales FROM users "
				+ "INNER JOIN row_header ON row_header.name = users.name" + orderString + "LIMIT 20");
	}
	else {
		rs3 = stmt3.executeQuery("WITH row_header(id, name, totalsales) AS (SELECT users.id AS id, users.name AS name, "
				+ "SUM(orders.price) AS totalsales FROM users INNER JOIN orders on users.id = orders.user_id INNER JOIN "
				+ "products on orders.product_id = products.id WHERE products.category_id = " + filterString
				+ " GROUP BY users.id) SELECT DISTINCT LEFT(users.name, 10) AS name, users.id AS id, row_header.totalsales AS totalsales FROM users "
				+ "INNER JOIN row_header ON row_header.name = users.name" + orderString + "LIMIT 20");
	}
	
	while (rs3.next()) { %>
		<tr>
			<th><%=rs3.getString("name") %>(<%=rs3.getFloat("totalsales") %>)</th>
	<% 		
	if (filterString.equals("All")) {
		rs2 = stmt2.executeQuery("WITH col_header(product_id, totalsales) AS (SELECT product_id, SUM(orders.price) "
				+ "AS totalsales FROM orders GROUP BY product_id) SELECT products.id AS id, products.name AS name, col_header.totalsales "
				+ "AS totalsales FROM products INNER JOIN col_header ON products.id = col_header.product_id "
				+ orderString + "LIMIT 10");
	}
	else {
		rs2 = stmt2.executeQuery("WITH col_header(product_id, totalsales) AS (SELECT product_id, SUM(orders.price) "
				+ "AS totalsales FROM products INNER JOIN orders on orders.product_id = products.id WHERE "
				+ "products.category_id = " + filterString + " GROUP BY product_id) SELECT products.id AS id, products.name AS name, "
				+ "col_header.totalsales AS totalsales FROM products INNER JOIN col_header ON products.id = col_header.product_id"
				+ orderString + "LIMIT 10");
	}
	
	while (rs2.next()) {
		Statement stmt4 = conn.createStatement();
		ResultSet rs4 = stmt4.executeQuery("SELECT SUM(orders.price) AS totalprices FROM orders where orders.product_id = "
							+ rs2.getString("id") + " AND orders.user_id = " + rs3.getString("id") + " GROUP BY "
							+ "orders.product_id, orders.user_id");
		
		if (rs4.next()) { %>
			<td><%=rs4.getFloat("totalprices")%></td>
		<% }
		else {%>
			<td>0</td>
		<% }
		}
	 %> </tr>
	<% }
} %>
</table>
<div class="form-group">
	<form action="orders.jsp" method="POST">
	<% if ((Integer)session.getAttribute("rowNum") + 20 <= (Integer)session.getAttribute("customerNum")) { %>
		<td>
			<input type="hidden" name="rowNext" value="clicked" />
			<input class="btn btn-primary" type="submit" value="Next 20 Customers" />
		</td> 
	<% } 
		if ((Integer)session.getAttribute("colNum") + 10 <= (Integer)session.getAttribute("productNum")) { %>
		<td>
			<input type="hidden" name="colNext" value="clicked" />
			<input class="btn btn-primary" type="submit" value="Next 10 Products" />
		</td>
	<% } %>
	</form>
</div>
</body>
</html>