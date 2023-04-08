% Editing Sublime Text packages
% Pierre Chapuis
% 2014-03-03 21:30:00

<!--@
  description = "How to change the behavior of Lua autocompletion in Sublime Text."
-->

I have finally decided to configure Sublime Text 2 to have it autocomplete
Lua code the way I want it to.

For instance, by default, when you start typing `function` and hit TAB,
you get the following result:

    lang: lua
    function function_name( ... )
      -- body
    end

Instead I wanted this:

    lang: lua
    function(self)
      error("unimplemented")
    end

It turns out this is very simple. Go to `Preferences -> Browse Packages...`
and open the Lua directory. There are several files there, including two
named *function-(fun).sublime-snippet* and *function-(function).sublime-snippet*
which do almost the same thing.

Remove the first one and open the second one in a text editor. Its content
should be something like:

    <snippet>
        <content><![CDATA[function ${1:function_name}( ${2:...} )
        ${0:-- body}
    end]]></content>
        <tabTrigger>function</tabTrigger>
        <scope>source.lua</scope>
        <description>function</description>
    </snippet>

Replace it by:

    <snippet>
        <content><![CDATA[function(${1:self})
        ${0:error("unimplemented")}
    end]]></content>
        <tabTrigger>function</tabTrigger>
        <scope>source.lua</scope>
        <description>function</description>
    </snippet>

... and that is all, the deed is done!
