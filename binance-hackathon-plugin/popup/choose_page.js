console.log("test")
document.addEventListener("click", function(e) {
  /*if (!e.target.classList.contains("login")) {
    return;
  }*/
  var img=document.createElement("img");
  img.src="http://ec2-18-216-165-179.us-east-2.compute.amazonaws.com/img/home.png";
  var body = document.getElementsByTagName("body")[0];
  img.width=400;
  while (body.firstChild) {
    body.removeChild(body.firstChild);
  }
  body.appendChild(img);
  //console.log("done")
});
