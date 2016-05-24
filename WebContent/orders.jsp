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
	String filter = request.getParameter("filter");
	String rowNext = request.getParameter("rowNext");
	String colNext = request.getParameter("colNext");
	String clear = request.getParameter("clear");

	if (clear != null && clear.equals("clicked")) {
		session.setAttribute("allowedToEdit", "yes");
		session.setAttribute("run", "not");
		session.setAttribute("rowNum", 0);
		session.setAttribute("colNum", 0);
		session.setAttribute("productNum", 0);
		session.setAttribute("customerNum", 0);
	}
	
	if (rows != null) {
		if (rows.equals("Customers")) {
			session.setAttribute("rowsString", "Customers");
			session.setAttribute("rows", "Customers");	
		}
		else {
			session.setAttribute("rowsString", "States");
			session.setAttribute("rows", "States");
		}
	}
	
	if (order != null) {
		session.setAttribute("order", order);
		if (order.equals("Top-K")) {
			session.setAttribute("orderString", " ORDER BY totalsales DESC ");
			session.setAttribute("order", "Alphabetical");
		}
		else {
			session.setAttribute("orderString", " ORDER BY name ");
			session.setAttribute("order", "Top-K");
		}
	}
	
	if (filter != null) {
		if (filter.equals("All")) {
			session.setAttribute("filter", "All");
			session.setAttribute("filterString", "All");
		}
		
		else {
			session.setAttribute("filterString", filter);
			Statement stmt = conn.createStatement();
			ResultSet rs = stmt.executeQuery("SELECT name FROM categories WHERE id = " + filter);
			if (rs.next())
				session.setAttribute("filter", rs.getString("name"));
		}
	}
	
	if (session.getAttribute("rowsString") == null)
		session.setAttribute("rowsString", "Customers");
	
	if (session.getAttribute("orderString") == null)
		session.setAttribute("orderString", "Alphabetical");
	
	if (session.getAttribute("filterString") == null)
		session.setAttribute("filterString", "All");
	
	if (session.getAttribute("run") == null)
		session.setAttribute("run", "not");
	
	if (session.getAttribute("allowedToEdit") == null)
		session.setAttribute("allowedToEdit", "yes");
	
	if (session.getAttribute("rowNum") == null) 
		session.setAttribute("rowNum", 0);
	
	if (rowNext != null && rowNext.equals("clicked")) {
		session.setAttribute("rowNum", (Integer)session.getAttribute("rowNum") + 20);
		session.setAttribute("allowedToEdit", "no");
	}
	
	if (session.getAttribute("colNum") == null) 
		session.setAttribute("colNum", 0);
	
	if (colNext != null && colNext.equals("clicked")) {
		session.setAttribute("colNum", (Integer)session.getAttribute("colNum") + 10);
		session.setAttribute("allowedToEdit", "no");
	}
	
	if(session.getAttribute("productNum") == null)
		session.setAttribute("productNum", 0);
	
	if(session.getAttribute("customerNum") == null)
		session.setAttribute("customerNum", 0);
	
	Statement stmtP = conn.createStatement();
	ResultSet rsP = stmtP.executeQuery("SELECT COUNT(*) as num FROM (SELECT name FROM products GROUP BY name) product");
	if (rsP.next()) 
		session.setAttribute("productNum", rsP.getInt("num"));
	
	Statement stmtC = conn.createStatement();
	ResultSet rsC = stmtC.executeQuery("SELECT COUNT(*) as num FROM (SELECT name FROM users GROUP BY name) customer");
	if (rsC.next()) 
		session.setAttribute("customerNum", rsC.getInt("num"));
	
	if ("POST".equalsIgnoreCase(request.getMethod())) {
		String action = request.getParameter("action");
		if (action != null && action.equals("runQuery")) {
			session.setAttribute("run", action);
			session.setAttribute("colNum", 0);
			session.setAttribute("rowNum", 0);
		}
	}

	String rowsString = (String)session.getAttribute("rowsString");
	String orderString = (String)session.getAttribute("orderString");
	String filterString = (String)session.getAttribute("filterString");
	
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
	
	String noFilter = "WITH col_header(product_id, totalsales) AS (SELECT product_id, SUM(orders.price) "
			+ "AS totalsales FROM orders GROUP BY product_id) SELECT products.id AS id, products.name AS name, col_header.totalsales "
			+ "AS totalsales FROM products INNER JOIN col_header ON products.id = col_header.product_id "
			+ orderString + "LIMIT 10 OFFSET " + session.getAttribute("colNum");
	
	String withFilter = "WITH col_header(product_id, totalsales) AS (SELECT product_id, SUM(orders.price) "
			+ "AS totalsales FROM products INNER JOIN orders on orders.product_id = products.id WHERE "
			+ "products.category_id = " + filterString + " GROUP BY product_id) SELECT products.id AS id, products.name AS name, "
			+ "col_header.totalsales AS totalsales FROM products INNER JOIN col_header ON products.id = col_header.product_id"
			+ orderString + "LIMIT 10 OFFSET " + session.getAttribute("colNum");
	
	Statement stmt2 = conn.createStatement();
	ResultSet rs2;
	
	if (filterString.equals("All")) {
		rs2 = stmt2.executeQuery(noFilter);
	}
	else {
		rs2 = stmt2.executeQuery(withFilter);
	} %>

<table class="table table-striped">
	<th></th>
	<% while (rs2.next()) { %>
		<th><%=rs2.getString("name")%> (<%=rs2.getFloat("totalsales") %>)</th>	
	<% }
	
	String noFilter2 = "WITH row_header(id, name, totalsales) AS (SELECT users.id AS id, users.name AS name, "
			+ "SUM(orders.price) AS totalsales FROM users INNER JOIN orders on users.id = orders.user_id "
			+ "GROUP BY users.id) SELECT DISTINCT LEFT(users.name, 10) AS name, users.id AS id, row_header.totalsales AS totalsales FROM users "
			+ "INNER JOIN row_header ON row_header.name = users.name" + orderString + "LIMIT 20 OFFSET " + session.getAttribute("rowNum");
	
	String withFilter2 = "WITH row_header(id, name, totalsales) AS (SELECT users.id AS id, users.name AS name, "
			+ "SUM(orders.price) AS totalsales FROM users INNER JOIN orders on users.id = orders.user_id INNER JOIN "
			+ "products on orders.product_id = products.id WHERE products.category_id = " + filterString
			+ " GROUP BY users.id) SELECT DISTINCT LEFT(users.name, 10) AS name, users.id AS id, row_header.totalsales AS totalsales FROM users "
			+ "INNER JOIN row_header ON row_header.name = users.name" + orderString + "LIMIT 20 OFFSET " + session.getAttribute("rowNum");
	
	Statement stmt3 = conn.createStatement();
	ResultSet rs3;
	
	if (filterString.equals("All")) {
		rs3 = stmt3.executeQuery(noFilter2);
	}
	else {
		rs3 = stmt3.executeQuery(withFilter2);
	}
	
	while (rs3.next()) { %>
		<tr>
			<th><%=rs3.getString("name") %>(<%=rs3.getFloat("totalsales") %>)</th>
	<% 		
	if (filterString.equals("All")) {
		rs2 = stmt2.executeQuery(noFilter);
	}
	else {
		rs2 = stmt2.executeQuery(withFilter);
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
%>
</table>
<div>
	<form action="orders.jsp" method="POST">
	<% if ((Integer)session.getAttribute("colNum") + 10 <= (Integer)session.getAttribute("productNum")) { %>
		<td>
			<input type="hidden" name="colNext" value="clicked" />
			<input class="btn btn-primary" type="submit" value="Next 10 Products" />
		</td>
	<% } %>
	</form>
	<form action="orders.jsp" method="POST">
	<% if ((Integer)session.getAttribute("rowNum") + 20 <= (Integer)session.getAttribute("customerNum")) { %>
		<td>
			<input type="hidden" name="rowNext" value="clicked" />
			<input class="btn btn-primary" type="submit" value="Next 20 Customers" />
		</td> 
	<% } %>
	</form>
	<form action="orders.jsp" method="POST">
		<td>
			<input type="hidden" name="clear" value="clicked" />
			<input class="btn btn-primary" type="submit" value="Clear" />
		</td> 	
	</form>
</div>
<% } %>
</body>
</html>