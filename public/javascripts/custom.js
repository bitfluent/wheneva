$(document).ready(function() {
  Cufon.replace('h1');
  Cufon.replace('h2');
  Cufon.replace('h3');
  Cufon.replace('h4');
  Cufon.replace('h5');
  Cufon.replace('h6');

  $("#request_date_dummy").val($("#date_picker li a.selected").text());
  $("#appointment_requested_date_chronic").val($("#date_picker li a.selected").text());

  $("#date_picker li a").click(function() {
    $("#appointment_requested_date_chronic").val($(this).text());
    $("#request_date_dummy").val($(this).text());
    $("#date_picker li a.selected").removeClass("selected");
    $(this).addClass("selected");
    return false;
  });
});
