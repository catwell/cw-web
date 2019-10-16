// Email obfuscator script 2.1 by Tim Williams, University of Arizona
// Random encryption key feature by Andrew Moulden, Site Engineering Ltd
// This code is freeware provided these four comment lines remain intact
// A wizard to generate this code is at http://www.jottings.com/obfuscator/
// Adapted by Pierre Chapuis.

function cw_email () {
  var coded = "f8c1@tDYEn55.f8c1"
  var key = "VELa5NjW4KsvteGmBbQ0DCTidxJzrYnhpOuUFk7ofyPASZw8XlH2MR6I1c39qg"
  var shift = coded.length
  var link = ""
  var ltr
  for (i=0; i<coded.length; i++) {
    if (key.indexOf(coded.charAt(i))==-1) {
      ltr = coded.charAt(i);
      link += (ltr);
    }
    else {
      ltr = (key.indexOf(coded.charAt(i))-shift+key.length) % key.length;
      link += (key.charAt(ltr));
    }
  }
  return link;
}
