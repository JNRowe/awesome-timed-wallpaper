awesome-timed-wallpaper
=======================

.. epigraph::

    For Léna.

A quick – and frankly quite dirty – hack to use gnome-style timed wallpapers
with awesomewm_.

``awesome-timed-wallpaper`` is released under the `LGPL v2.1`_ license, as it is
based entirely around the data from the
``themes/Adwaita/backgrounds/adwaita-timed.xml`` file in
``gnome-themes-standard``.  That file was, according to the `git history`_,
created by Jakub Steiner (jimmac).

Quick Usage
-----------

You'll need ImageMagick_ installed, as it is used to blend the images.

Add the following snippet to your ``rc.moon``

.. code:: moonscript

    wallpaper = require "adwaita-timed"

    with timer timeout: 3*60
        \connect_signal "timeout", (using nil) ->
            if bg_file = wallpaper!
                for s = 1, screen.count!
                    gears.wallpaper.centered bg_file, s, "solid:#000000"
        \emit_signal "timeout"
        \start!

Why?
----

Simple, I've badgered Léna about switching window managers for some time now.
Mostly because many of the lunchtime complaints she makes about her current
setup are *already* solved by a different window manager.

However, that of course means I'm on the hook when functionality she relied on
doesn't exist with that new choice.  And apparently wallpaper that changes
throughout the day is item one on the list.

This **dirty** hack just adds simplistic support for the Adwaita backgrounds she
uses to awesomewm_.  It should serve mostly as an example of using timers and
such, but it is functional.

[The solution I'd actually recommend is to use one of the many tiling layouts
and never see your wallpaper again 😏]

How?
----

There are *plenty* of better and smarter ways to do this, but this is a fifteen
minute hack(and ten of those were spent writing this very document).

Basically we have a timer which calls a function to generate the wallpaper as
it should be at this moment.  We generate the wallpapers using ``composite``
from ImageMagick_, and cache them so that after a couple of days we're no longer
calling ``composite`` every three minutes.

The overhead for composite isn't all the great, but if you can afford the ~50MB
the full cache takes it makes sense.

We're also somewhat careful to not actually change the wallpaper unless it has
actually changed.  It doesn't make a great deal of difference, but also doesn't
take a great deal of effort to implement.

Configuration
-------------

If you're using awesomewm_, you should be used to customising lua_ or
moonscript_ by now.

The specific things you'll probably want to change are:

================   ======  ================================
Variable           Type    Use
================   ======  ================================
``adwaita_path``   string  Location of Adwaita theme
``size``           table   Resolution to generate images at
================   ======  ================================

For example, if you're running Debian you may need to use
``/usr/share/backgrounds/gnome`` as the path to the background images.

The future
----------

If people would like to see a more generic framework for implementing this sort
of behaviour then open an issue, and I'll probably get to it.  As things stand
this does what I was told to implement, and no more.

Simple improvements could include:

* moving the data definition to a table for easy customisation from ``rc.moon``
* using cairo_ or gdk-pixbuf_ via lgi_ to composite the images instead of
  shelling out to ImageMagick_

Contributors
------------

I'd like to thank the following people who have contributed to
``awesome-timed-wallpaper``.

Patches
'''''''

* <your name here>

Bug reports
'''''''''''

* <your name here>

Ideas
'''''

* Léna Franck

If I've forgotten to include your name I wholeheartedly apologise.  Just drop me
a mail_ and I'll update the list!

Bugs
----

If you find any problems, bugs or just have a question about this package either
file an issue_ or drop me a mail_.

If you've found a bug please attempt to include a minimal testcase so I can
reproduce the problem, or even better a patch!

.. _awesomewm: http://awesome.naquadah.org/
.. _LGPL v2.1: http://www.gnu.org/licenses/
.. _git history: https://git.gnome.org/browse/gnome-themes-standard/
.. _ImageMagick: http://www.imagemagick.org/
.. _lua: http://www.lua.org/
.. _moonscript: https://github.com/leafo/moonscript/
.. _cairo: http://cairographics.org/
.. _gdk-pixbuf: https://git.gnome.org/browse/gdk-pixbuf
.. _lgi: https://github.com/pavouk/lgi
.. _issue: https://github.com/JNRowe/awesome-timed-wallpaper/issues
.. _mail: jnrowe@gmail.com
