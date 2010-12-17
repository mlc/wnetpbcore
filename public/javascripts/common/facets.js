$(function() {
    $(".sidebarSearchLinks a").click(function() {
	$(this).closest("tr").next().slideToggle();
	return false;
    });
    $("a.morelink").click(function() {
        var $this = $(this), possible = $this.data('possible'), shown = $this.data('shown');
        $($this.parent("td").find(".rowset")[shown]).slideToggle();
        shown++;
        $this.data('shown', shown);
        if (possible === shown) {
          $this.remove();
        }
        return false;
    });
});