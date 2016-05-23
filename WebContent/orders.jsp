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
	
	if (filter == null)
		session.setAttribute("filter", "All");
	else {
		session.setAttribute("filter", filter);
		filterString = filter;
	}
	
	if (session.getAttribute("run") == null)
		session.setAttribute("run", "not");
	
	if ("POST".equalsIgnoreCase(request.getMethod())) {
		String action = request.getParameter("action");
		if (action != null && action.equals("runQuery")) {
			session.setAttribute("run", action);
			response.sendRedirect("orders.jsp");
		}
	}
	
	Statement stmt = conn.createStatement();
	ResultSet rs = stmt.executeQuery("SELECT id, name FROM categories");
	
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
  	<% while (rs.next()) { 	
  		if (!rs.getString("id").equals((String)session.getAttribute("filter"))) { %>
  		<option value="<%=rs.getString("id")%>"><%=rs.getString("name")%></option>
  	<%  }
  	}
  	if (!((String)session.getAttribute("filter")).equals("All")) %>
		<option value="All">All</option>
	</select>
	<input class="btn btn-primary" type="submit" value="Run Query"/>
</form>
</div>

<% if (((String)session.getAttribute("run")).equals("runQuery")) { 
	
	Statement stmt2 = conn.createStatement();
	ResultSet rs2;
	
	if (filterString.equals("All")) {
		rs2 = stmt.executeQuery("WITH col_header(product_id, totalsales) AS (SELECT product_id, SUM(orders.price) "
				+ "AS totalsales FROM orders GROUP BY product_id) SELECT products.name AS name, col_header.totalsales "
				+ "AS totalsales FROM products INNER JOIN col_header ON products.id = col_header.product_id "
				+ orderString + "LIMIT 10");
	}
	else {
		rs2 = stmt.executeQuery("WITH col_header(product_id, totalsales) AS (SELECT product_id, SUM(orders.price) "
				+ "AS totalsales FROM orders INNER JOIN products on orders.product_id = products.id WHERE "
				+ "products.category_id = " + filterString + " GROUP BY product_id) SELECT products.name AS name, "
				+ "col_header.totalsales AS totalsales FROM products INNER JOIN col_header ON products.id = col_header.product_id"
				+ orderString + "LIMIT 10");
	} %>
<table class="table table-striped">
	<th></th>
	<% while (rs2.next()) { %>
		<th><%=rs2.getString("name")%> (<%=rs2.getFloat("totalsales") %>)</th>	
	<% } 
	} %>
</table>
</body>
</html>