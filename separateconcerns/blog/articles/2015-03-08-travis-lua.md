% Continuous Integration for Lua with Travis
% Pierre Chapuis
% 2015-03-08 12:00:00

<!--@
  description = "Add automated testing to your Lua open source projects for free."
  updated = "2015-10-16 16:30:00"
-->

[Travis](https://travis-ci.org) is a Continuous Integration service which is free for Open Source projects and has very good GitHub integration. We will see how to use it for your Lua projects.

Your test suite will work well with Travis as long as executing it returns 0 on success and nonzero on failure. If you use plain Lua assertions, it is already the case. If you use a test framework, make sure that it works that way. I have added [a helper](https://github.com/catwell/cwtest#exit) to cwtest for that purpose.

Travis does not support Lua out of the box, but using it with Lua projects is not hard because [moteus](https://github.com/moteus) has done all the hard work for you. You just have to clone [this repository](https://github.com/moteus/lua-travis-example) and copy the `.travis` directory to yours.

After that, you only have to write a single YAML file, `.travis.yml`. For example, here is [the one I wrote for Haricot](https://github.com/catwell/haricot/blob/master/.travis.yml).

Most sections should be self-explanatory. `install` is where you set up your dependencies. The first line calls moteus' script which lets you use Lua and LuaRocks. A separate build and test run will occur for every Lua version declared in `matrix`; you can comment some lines there if you do not want to test some Lua versions. For Haricot I need [Beanstalk](http://kr.github.io/beanstalkd/) running in the background so I start it in `before_script`. `script` is where you run your actual tests.

To enable Travis, sign up, allow Travis to access your GitHub account, then go to [your profile](https://travis-ci.org/profile) and flip the switch for your repository:

![travis](img/travis.png)

After that, commit `.travis` and `.travis.yml` and push to GitHub. It will trigger a test build, and so will every subsequent commit. If you want, you can now add [a badge](https://travis-ci.org/catwell/haricot.png?branch=master) with the status of your build to your README or your project's home page.
