$(document).ready(function() {

  $('.box').click(function(event) {
    event.preventDefault();
    var xOrO = "X"
    $(event.target).html("<h1>" + symbol +"</h1>");
    send("move",$(event.target).attr('id'))
  });
});

function updateBoard(cord){
  if(symbol==="O"){
    $('#'+cord).html('<h1>X</h1>')
  }
  else{
   $('#'+cord).html('<h1>O</h1>')
  }
}


$('#setAlias').click(function(){
  connect();
})


