$(function() {
    $(".sidebarSearchLinks a").click(function() {
	$(this).closest("tr").next().slideToggle();
	return false;
    });
});