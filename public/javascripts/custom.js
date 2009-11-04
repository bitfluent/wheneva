$(document).ready(function() {
  Cufon.replace('h1');
  Cufon.replace('h2');
  Cufon.replace('h3');
  Cufon.replace('h4');
  Cufon.replace('h5');
  Cufon.replace('h6');

  $("#appointment_requested_date").val($("#date_picker li a.selected").text());

  $("#date_picker li a").click(function() {
    $("#appointment_requested_date").val($(this).text());
    $("#date_picker li a.selected").removeClass("selected");
    $(this).addClass("selected");
    return false;
  });
});
