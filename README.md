WalkingBass
===========
This MuseScore 4.4+ plugin generates a walking bass line, based on the chords in the selected staff.

Given a particular chord, a pattern of notes is chosen to insert for the chord's duration.  More information about the usage of patterns in walking bass lines can be found in the [Patterns](https://github.com/philxan/WalkingBass/blob/main/Patterns.md) documentation.

The user can choose whether to generate:
* The lowest note used. Typically this will be E1 (open E string on a double bass - midi 28) 
* The range of notes used, specified in octaves. (Default as 2.5, although 3 is also a good choice)
* How frequently to use a larger interval spaced interval, rather the closest one
* Whether to include the pattern being used
* Whether to convert the generated notes to slashes ( "/" ), as would typically be written in a jazz chart
* Whether to use patterns that do not begin on the root of the chord, and how frequently

Changes for this version:
------------------------
* Restricted to MuseScore 4.4 and later, due to Qt changes.
* Added Settings and About dialogs for cleaner user interface. 
* Changed the available range of notes to be "Lowest Pitch" and "Highest Pitch" (instead of "Lowest Pitch" & "Octave Range")
* Added "skips" option to include quaver skip notes
* Added 2 bar patterns. When the exact same chord is used for 2 bars in a row, there is a 50% chance that 2 bar pattern will be used. 
* Fixed an issue where if a non-root note has an v approach note, it is now changed to a or b for smoother walking

Usage
-----
To use this plugin, select bars in a single staff that contains chord symbols. Only one staff can be selected: selecting multiple staves an error message will be displayed and no notes will be inserted. Likewise, if no chord symbols are detected error message will be displayed and no notes will be inserted. 

All generated notes are added to voice 1 of the selected staff. Any existing notes in that voice in that staff will be overwritten.

The following chord symbol features are supported in the current version:
Feature | Example
------- | -------
*letter*[b ♭ # ♯] | A, Bb, C#
Major, major, Maj, maj, Ma, ma, M, j | Cma, DM7
minor, min, mi, m, -, − | Dmi, D-9
dim, o, ° | Ebdim, E°7
ø, O, 0 | Abø7
aug, + | Db+
t, ∆, ^ | C∆7
69, | G69
*number* | C7, E13
(Major, major, Maj, maj, Ma, ma, M, j *number*) | Cmi(ma7)
alt | Dalt
sus[*number*] | Asus, Dsus2
b*number* ... | C7b5b9
#*number* ... | Eb7#9#11
/ *letter*[b #] | D7/A

You may enclose parts of the chord symbol in parentheses, for example "C9(#5)".

Installation
-------------
To install the plugin:
1. Download the file WalkingBass-v4.4.zip
1. Expand the zip file. The result is a folder "WalkingBass-v4.4"
1. Move the WalkingBass folder into your MuseScore Plugins folder, which can be found here:
   * Windows: %HOMEPATH%\Documents\MuseScore4\Plugins
   * Mac: ~/Documents/MuseScore4/Plugins
   * Linux: ~/Documents/MuseScore4/Plugins
1. Launch MuseScore 4
1. Select the menu item Plugins > Plugin Manager...
1. In the resulting dialog, enable WalkingBass
   
To use the plugin:
1. Select the menu item Plugins > WalkingBass…. The WalkingBass window will appear.
1. Select the staff where you want the walking bass line to be generated.  This should be in bass clef, and have chords to generate the walking bass line for. 
1. click Apply

Main Winddow Options
---------------------
The following configuration options are displayed in the Walking Bass main window

**Lowest Note**
This is the loweset note that will be generated, expressed as a midinote. The default is 'E1' (midi note 28) which is the open E string of a double bass or bass guitar. This is the E below C, below middle C on the piano. It is the E below the bass clef staff. Rarely should this need to be changed. If writing for a 5-string bass with a bottom B string, specify B0. 

**Highest Note**
This is the highest note that will be generated, expressed as a midinote. The default is 'G3' (midi note 55) which is an octave above the the open G string of a double bass or bass guitar. 

**Write slashes instead of notes**
If selected, then notes will not be displayed. Instead they will displayed as stemless slashes: " / ".  This does not affect playback - the notes will be played as generated. This option creates scores that are more usually found in jazz charts for bass players. 

Settings Winddow Options
---------------------
The following options are displaying in the Settings window

**Non-root patterns (%)**
This is the percentage chance that a pattern that does not start on the root note is selected for use. 0% means that non-root patterns will never be used. 100% means that non-root patterns will _always_ be used. 

**Repeat-note Octaves (%)**
This is the percentage chance that a repeated note in a pattern is repeated an octave above or below, rather than the same pitch. For example, in the pattern 1-1-2-5, the second root note (the second "1") may be in the same pitch, or may be an octave apart from the first one. 

**Skips (%)**
This is the percentage chance that a note will be split from a single quarter note (crotchet) into two eighth notes (quavers).  Additionally, there is a 50% chance that the second eighth note will be a dead note, noted using a 'x' for the note head. 

**Flip (%)**
This is the percentage chance that a note will be "flipped" from being the closest interval. It only applies to notes from the minor third to the major sixth. The second and the seventh will always be the notes that are closest to the root. 
For example, when a pattern specifies to play the root then the third, this will typically be the third _above_ the root, as that is closest.  However this could also be "flipped" to be the third _below_ the root - essentially an interval of a 6th. Keeping this value a small results in smoother lines, with some wider variations. A higher value will result in more widely jumping bass lines. 

**Include the pattern text**
If selected, then the pattern being used will be written as text below the first note of the pattern. 

If you have any comments or suggestions for further improvements, please don't hesitate to contact me. 

Phil Kan (pitdadphil@gmail.com)
December, 2023.
