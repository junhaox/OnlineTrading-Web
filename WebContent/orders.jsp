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
	
	if ("POST".equalsIgnoreCase(request.getMethod())) {
		String rows = request.getParameter("Rows");
		if (rows != null && rows.equals("States"))
			response.sendRedirect("stateProducts.jsp");
	}
	
	String order = request.getParameter("Order");
	Statement stmt = conn.createStatement();
	Statement stmt2 = conn.createStatement();
	ResultSet rs = stmt.executeQuery("SELECT * FROM products ORDER BY name LIMIT 20");
	ResultSet rs2 = stmt2.executeQuery("SELECT name FROM categories");
	
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
  	<label for="Rows">Rows:</label>
  	<select name="Rows" id="rows" class="form-control">
	    <option value="Customers">Customers</option>
	    <option value="States">States</option>
	</select>	
  	<label for="Order">Order:</label>
  	<select name="Order" id="order" class="form-control">
	    <option value="Alphabetical">Alphabetical</option>
	    <option value="Top-K">Top-K</option>
	</select>
	<label for="Sales">Sales Filtering Option:</label>
  	<select name="Sales" id="sales" class="form-control">
  	<% while (rs2.next()) { %>
  		<option value="<%=rs2.getString("name")%>"><%=rs2.getString("name")%></option>
  	<% } %>
	</select>
	<input class="btn btn-primary" type="submit" name="submit" value="Run Query"/>
</form>
</div>

</body>
</html>