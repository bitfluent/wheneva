$(document).ready(function() {
  Cufon.replace('h1');
  Cufon.replace('h2');
  Cufon.replace('h3');
  Cufon.replace('h4');
  Cufon.replace('h5');
  Cufon.replace('h6');

  $(".date_confirm").text($("#date_picker li a.selected").text());

  $("#date_picker li a").click(function() {
    $(".date_confirm").text($(this).text());
    $("#date_picker li a.selected").removeClass("selected");
    $(this).addClass("selected");
    return false;
  });
});
