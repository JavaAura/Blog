<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Manage Comments</title>
    <link href="https://cdn.jsdelivr.net/npm/tailwindcss@2.2.19/dist/tailwind.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.15.3/css/all.min.css">
</head>
<body class="bg-gray-100">
    <div class="container mx-auto px-4 py-8">
        <h1 class="text-3xl font-bold mb-6">Manage Comments</h1>
        
        <div class="bg-white shadow-md rounded-lg overflow-hidden">
            <table class="min-w-full">
                <thead class="bg-gray-200">
                    <tr>
                        <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Content</th>
                        <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Author</th>
                        <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Article</th>
                        <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Status</th>
                        <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Actions</th>
                    </tr>
                </thead>
                <tbody class="divide-y divide-gray-200">
                    <c:forEach var="comment" items="${comments}">
                        <tr>
                            <td class="px-6 py-4 whitespace-nowrap">${comment.content}</td>
                            <td class="px-6 py-4 whitespace-nowrap">${comment.author.name}</td>
                            <td class="px-6 py-4 whitespace-nowrap">${comment.article.title}</td>
                            <td class="px-6 py-4 whitespace-nowrap">${comment.status}</td>
                            <td class="px-6 py-4 whitespace-nowrap">
                                <c:choose>
                                    <c:when test="${sessionScope.userRole eq 'Editor' and comment.author.email ne sessionScope.loggedInUser}">
                                        <form action="${pageContext.request.contextPath}/comment/updateStatus" method="post" class="inline">
                                            <input type="hidden" name="commentId" value="${comment.id}">
                                            <select name="status" onchange="this.form.submit()" class="bg-gray-200 rounded px-2 py-1 text-sm">
                                                <option value="approved" ${comment.status eq 'approved' ? 'selected' : ''}>Approved</option>
                                                <option value="rejected" ${comment.status eq 'rejected' ? 'selected' : ''}>Rejected</option>
                                            </select>
                                        </form>
                                    </c:when>
                                    <c:when test="${sessionScope.userRole eq 'Editor' and comment.author.email eq sessionScope.loggedInUser}">
                                        <button class="bg-blue-500 hover:bg-blue-600 text-white py-1 px-2 rounded text-sm mr-2" onclick="openEditPopup(${comment.id}, '${comment.content}')">Edit</button>
                                        <form action="${pageContext.request.contextPath}/comment/delete" method="post" class="inline mr-2">
                                            <input type="hidden" name="commentId" value="${comment.id}">
                                            <button type="submit" class="bg-red-500 hover:bg-red-600 text-white py-1 px-2 rounded text-sm">Delete</button>
                                        </form>
                                        <form action="${pageContext.request.contextPath}/comment/updateStatus" method="post" class="inline">
                                            <input type="hidden" name="commentId" value="${comment.id}">
                                            <select name="status" onchange="this.form.submit()" class="bg-gray-200 rounded px-2 py-1 text-sm">
                                                <option value="approved" ${comment.status eq 'approved' ? 'selected' : ''}>Approved</option>
                                                <option value="rejected" ${comment.status eq 'rejected' ? 'selected' : ''}>Rejected</option>
                                            </select>
                                        </form>
                                    </c:when>
                                    <c:when test="${comment.author.email eq sessionScope.loggedInUser}">
                                        <button class="bg-blue-500 hover:bg-blue-600 text-white py-1 px-2 rounded text-sm mr-2" onclick="openEditPopup(${comment.id}, '${comment.content}')">Edit</button>
                                        <form action="${pageContext.request.contextPath}/comment/delete" method="post" class="inline">
                                            <input type="hidden" name="commentId" value="${comment.id}">
                                            <button type="submit" class="bg-red-500 hover:bg-red-600 text-white py-1 px-2 rounded text-sm">Delete</button>
                                        </form>
                                    </c:when>
                                </c:choose>
                            </td>
                        </tr>
                    </c:forEach>
                </tbody>
            </table>
        </div>
        
        <div class="mt-6">
            <a href="${pageContext.request.contextPath}/dashboard.jsp" class="bg-gray-500 hover:bg-gray-600 text-white py-2 px-4 rounded">Back to Dashboard</a>
        </div>
    </div>
    <div id="editPopup" class="fixed inset-0 bg-gray-600 bg-opacity-50 overflow-y-auto h-full w-full hidden">
      <div class="relative top-20 mx-auto p-5 border w-96 shadow-lg rounded-md bg-white">
        <h3 class="text-lg font-medium leading-6 text-gray-900 mb-2">Edit Comment</h3>
        <textarea id="editCommentContent" class="w-full p-2 border rounded mb-4" rows="3"></textarea>
        <div class="flex justify-end">
          <button onclick="closeEditPopup()" class="bg-gray-500 hover:bg-gray-600 text-white py-2 px-4 rounded mr-2">Cancel</button>
          <button onclick="submitEditComment()" class="bg-blue-500 hover:bg-blue-600 text-white py-2 px-4 rounded">Save</button>
        </div>
      </div>
    </div>
    
    <script>
      let currentCommentId;
      
      function openEditPopup(commentId, content) {
        currentCommentId = commentId;
        document.getElementById('editCommentContent').value = content;
        document.getElementById('editPopup').classList.remove('hidden');
      }
      
      function closeEditPopup() {
        document.getElementById('editPopup').classList.add('hidden');
      }
      
      function submitEditComment() {
        const newContent = document.getElementById('editCommentContent').value;
        if (newContent.trim() !== "") {
          const form = document.createElement("form");
          form.method = "post";
          form.action = "${pageContext.request.contextPath}/comment/edit";
          
          const commentIdInput = document.createElement("input");
          commentIdInput.type = "hidden";
          commentIdInput.name = "commentId";
          commentIdInput.value = currentCommentId;
          form.appendChild(commentIdInput);
          
          const contentInput = document.createElement("input");
          contentInput.type = "hidden";
          contentInput.name = "content";
          contentInput.value = newContent;
          form.appendChild(contentInput);
          
          document.body.appendChild(form);
          form.submit();
        }
        closeEditPopup();
      }
    </script>
</body>
</html>