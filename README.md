# WalkingBass
This MuseScore 3 plugin generates a walking bass line, based on the chords in the selected staff.

Given a particular chord, a pattern of notes is chosen to insert for the chord's duration.  More information about the usage of patterns in walking bass lines can be found in the [Patterns](https://github.com/philxan/WalkingBass/edit/main/Patterns.md) documentation.

The user can choose whether to generate:
* The lowest note used. Typically this will be E2 (open E string on a double bass - midi 28) 
* The range of notes used, specified in octaves. (Default as 2.5, although 3 is also a good choice)
* Whether to include the pattern being used
* Whether to convert the generated notes to slashes ( "/" ), as would typically be written in a jazz chart
* Whether to use patterns that do not begin on the root of the chord. 


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
t, Δ, ∆, ^ | C∆7
69, | G69
*number* | C7, E13
(Major, major, Maj, maj, Ma, ma, M, j *number*) | Cmi(ma7)
alt | Dalt
sus[*number*] | Asus, Dsus2
b*number* ... | C7b5b9
#*number* ... | Eb7#9#11
/ *letter*[b #] | D7/A

You may enclose parts of the chord symbol in parentheses, for example "C9(#5)".

To install the plugin:
1. Download the file WalkingBass.zip
1. Expand the zip file. The result is a folder "WalkingBass"
1. Move the WalkingBass folder into your MuseScore Plugins folder, which can be found here:
   * Windows: %HOMEPATH%\Documents\MuseScore3\Plugins
   * Mac: ~/Documents/MuseScore3/Plugins
   * Linux: ~/Documents/MuseScore3/Plugins
1. Launch MuseScore3
1. Select the menu item Plugins > Plugin Manager...
1. In the resulting dialog, enable WalkingBass
   
To use the plugin:
1. Select the menu item Plugins > WalkingBass…. The WalkingBass panel will appear on the left hand side of the main screen, at the bottom. 
1. Select the staff where you want the walking bass line to be generated.  This should have a bass clef, and needs to have chords to generate the walking bass line for. 
1. click Apply

To download the plugin from this web page, use one of two methods below:
1. Click on WalkingBass.zip (above). This includes the plugin and all associated documentation
1. On the resulting page, click the button "Download", just above the text
1. Follow the installation steps above. 

or. 
1. Click on WalkingBass.qml (above). This is just the plugin, without any documentation, and is recommended only for advanved MuseScore users.
1. On the resulting page, click the button "Download", just above the text
1. Create a subdirectory for WalkingBass in the MuseScore Plugins folder, and copy the WalkingBass.qml file there. 
1. Restart MuseScore, and enable the pluginl

