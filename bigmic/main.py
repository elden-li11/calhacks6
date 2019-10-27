# Copyright 2018 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#	 http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# [START gae_python37_app]
from flask import Flask
import numpy as np
import scipy as sp


# If `entrypoint` is not defined in app.yaml, App Engine will look for an app
# called `app` in `main.py`.
app = Flask(__name__)

bad_script="""var dots = [],
	mouse = {
	  x: 0,
	  y: 0
	};

var Dot = function() {
  this.x = 0;
  this.y = 0;
  this.node = (function(){
	var n = document.createElement("div");
	n.className = "tail";
	document.body.appendChild(n);
	return n;
  }());
};
Dot.prototype.draw = function() {
  this.node.style.left = this.x + "px";
  this.node.style.top = this.y + "px";
};

for (var i = 0; i < 12; i++) {
  var d = new Dot();
  dots.push(d);
}

function draw() {
  var x = mouse.x,
	  y = mouse.y;
  
  dots.forEach(function(dot, index, dots) {
	var nextDot = dots[index + 1] || dots[0];
	
	dot.x = x;
	dot.y = y;
	dot.draw();
	x += (nextDot.x - dot.x) * .6;
	y += (nextDot.y - dot.y) * .6;

  });
}

addEventListener("mousemove", function(event) {
  mouse.x = event.pageX;
  mouse.y = event.pageY;
});

function animate() {
  draw();
  requestAnimationFrame(animate);
}

animate();"""

bad_css=""".tail {
	position: absolute;
	height: 6px; width: 6px;
	border-radius: 3px;
	background: tomato;
  }"""

@app.route('/')
def hello():
	"""Return a friendly HTTP greeting."""
	content = ""
	content += "<html><head><title>Title Page</title></head><body>"
	content += 'Hello World!' + "<style>"+bad_css+"<\style>" + "<script>"+bad_script+"<\script>" + str(np.sqrt(np.sum(np.square(np.array([1, 1])))))
	content += "</body></html>"
	return content


if __name__ == '__main__':
	# This is used when running locally only. When deploying to Google App
	# Engine, a webserver process such as Gunicorn will serve the app. This
	# can be configured by adding an `entrypoint` to app.yaml.
	app.run(host='127.0.0.1', port=8080, debug=True)
# [END gae_python37_app]
