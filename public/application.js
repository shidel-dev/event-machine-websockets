$(document).ready(function() {

  $('.box').click(function(event) {
    event.preventDefault();
    var xOrO = "X"
    $(event.target).html("<h1>" + xOrO +"</h1>");
    send("move",$(event.target).attr('id'))
  });
});

function updateBoard(cord){
  $('#'+cord).html('<h1>X</h1>')
}
