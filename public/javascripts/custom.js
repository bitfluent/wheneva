$(document).ready(function() {
  Cufon.replace('h1');
  Cufon.replace('h2');
  Cufon.replace('h3');
  Cufon.replace('h4');
  Cufon.replace('h5');
  Cufon.replace('h6');

  $("#request_date_dummy").val($("#date_picker li a.selected").text());
  $("#appointment_requested_date_chronic").val($("#date_picker li a.selected").text());
  $("#appointment_confirmed_date_chronic").val($("#date_picker li a.selected").text());

  $("#date_picker li a").click(function() {
    $("#appointment_requested_date_chronic").val($(this).text());
    $("#appointment_confirmed_date_chronic").val($(this).text());
    $("#request_date_dummy").val($(this).text());
    $("#date_picker li a.selected").removeClass("selected");
    $(this).addClass("selected");
    return false;
  });

  $("em.url").hide();
  $('.holder').cycle();

	// On admin appointment show
	$(".appointment_cancelled").click(function() {
		$("#appointment_cancelled").val('true');
	});
	$(".appointment_rejected").click(function() {
		$("#appointment_rejected").val('true');
	});
	$(".appointment_confirmed_date").click(function() {
		$("#appointment_confirmed_date").val($("#appointment_requested_date").val());
		$("#appointment_confirmed_date_chronic").val('');
		$(this).parents('form').submit();
	});
	
	// Generic link submit (.action)
	$(".action").not('.nosubmit').click(function() {
		$(this).parents('form').submit();
	});
	
	// For bookmarking feature
	if(window.opera) {
	    if ($("a.jqbookmark").attr("rel") != ""){ // don't overwrite the rel attrib if already set
	        $("a.jqbookmark").attr("rel","sidebar");
	    }
	}

	$("a.jqbookmark").click(function(event){
	    event.preventDefault(); // prevent the anchor tag from sending the user off to the link
	    var url = this.href;
	    var title = this.title;

	    if (window.sidebar) { // Mozilla Firefox Bookmark
	        window.sidebar.addPanel(title, url,"");
	    } else if( window.external ) { // IE Favorite
	        window.external.AddFavorite( url, title);
	    } else if(window.opera) { // Opera 7+
	        return false; // do nothing - the rel="sidebar" should do the trick
	    } else { // for Safari, Konq etc - browsers who do not support bookmarking scripts (that i could find anyway)
	         alert('Unfortunately, this browser does not support the requested action,'
	         + ' please bookmark this page manually.');
	    }

	});
	
	$("#account_subdomain").blur(function() {
	  $("em.url").hide();
	  if ($(this).val() == "") {
	    return;
	  }
	  $("em.check").show();
	  $.ajax({
	    url: "/accounts/check",
	    data: { "subdomain": $(this).val() },
	    dataType: "json",
	    success: function(data) {
	      $("em.check").hide();
	      if (data.taken) {
	        $("em.taken").show();
	      } else {
	        $("em.avail").show();
	      }
      }
	  });
	});
});
