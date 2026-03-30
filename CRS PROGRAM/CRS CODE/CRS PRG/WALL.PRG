#include "pw.ch"

function back_paper()
    pw():wallpaper(PWWP_RINGS, IIF(ISCOLOR(), "W/*N", "W/N"))
    && set wallpaper to PWWP_BRICKS
return nil
