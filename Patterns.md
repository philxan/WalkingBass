## Patterns

WalkingBass uses various patterns to randomaly generate the walking bass line. This is based on walking bass theory, frequently taught to bass players new playing a jazz walking bass line. 

The Basics
----------
WalkingBass creates a random walking bass line, based on the chords provided and a randomly selected pattern. Only quarter notes (crotchets) are used, as is common in these lines. Skips, triplets and other ornamentations are not considered at this time. 

The chords symbols recognised are included in the main [ReadMe](https://github.com/philxan/WalkingBass/blob/main/ReadMe.md) doucmentation. 

A _pattern_ is a series of numbers that represent the scale degrees to be played, relative to the current chord. Given the pattern "1-2-3-5", "1" indicates the root, "2", the second degree of the scale, "3", the third, and "5" the fifth. If the current chord is a C, and the given pattern is "1-2-3-5", then the notes C, D, E, and G would be played, in that order.  Note that in this case, the _major_ scale is implied, and the current key signature is NOT taken into account. 

Patterns are provided for 2 beats and 4 beats - typically a full bar, or a half a bar (where there are two chords in the same bar). If a chord lasts only for one beat, then the root is always played. If the chord lasts for longer than 4 beats, the multiple 4 beat patters are used, until the required length is reached. 

How Chords are Interpretted
---------------------------
For major chords, the major scale is natirally implied. If the chord is a 7, 9, or 13, the 7th degree is flattened so that it is interpretted as a dominant chord. 

For minor chords, the flat third (b3) and flat seventh (b7) are implied (the dorian mode). So, a pattern such as "1-3-5-7" for a Dm chord would generate the notes D, F, A, C.

For diminished chords, the "Half-Whole" scale is implied, with the following alterations (reletive to the major scale): 1 b2 b3 #4 b5 6
In this case, a 7 in the pattern will be adjusted to a 6 (double flat 7)

For augemented chords, the whole-tone scale is implied, with the following alterations (reletive to the major scale): 1 2 3 #4 #5 #6 7

For half-diminshed chords (minor 7, flat 5), the locrian scale is implied: 1 b2 b3 4 b5 b6 b7

Chord alterations and extensions are also taken into account. For example, the pattern "1-7-6-5" for a Cm7b13 would adjust the 6 down a semitone, as indicated by the b13.  This would result in the notes "C-Bb-Ab-G"

Patterns
--------
Commonly used patterns include arpeggios, and small scale runs. As above, these are altered as per the current chord. Most commonly these begin on the root (1) of the chord, and emphasize the third, seventh and fifth to outline the chord quality. These maybe ascending or descending. Lines that are commonly used include:
* 1-1-3-5
* 1-3-5-7
* 1-2-3-5
* 1-7-6-5
* 1-7-5-3
* _etc._

Approach Notes
--------
It is usual for walking bass line to use an _appraoch note_ of a semitone (halfstep) above or below the next note, or a fifth from the target note. Most commonly this is used as the last note of a four note pattern, when moving from one chord to the next one.  

Wwalking bass uses the values "a", "b", & "v" to indicate to use an approach note above, below, or the fifth of the target chord. 

For example, if the chord progression is a from C7 to F7, the bass line might use a pattern such as "1-3-5-**a**", resulting in:
* C-E-G-**F#** | F 

Or using an approach note below, such as "1-3-5-**b**"
* C-E-G-**E** | F 
Note that in this case, the "E" is both the third of the C chord, as well as a semitone below approach note. Two different patterns may result in the same notes for a given chord. 

However, in a chord progression such as Dm7 to G7, the "1-3-5-b" pattern would result in:
* D-F-A-F# | G 

The _a_ and _b_ approach notes are sometimes included in the middle of the pattern. A typical exmample is the common pattern "1-b-2-5" For a C7 this would result in the notes: 
* C-Db-D-G

The _a_ and _b_ approach notes are also very commonly used in a two beat pattern, together with the root. This provides very common walking lines for turn-arounds and rhythm changes. For example. considering the chord progression | C  Am7 | Dm7  G7 | C  :
* Using the pattern "1-a" exclusively: | C **B**  A **Eb** | D **Ab** G **Db** | C
* Using the pattern "1-b" exclusively: | C **G#** A **D#** | D **F#** G **B**  | C

In reality, WalkingBass would randomly chose a pattern for each chord, so it is much more likely that a combination of patterns are chosen. 

The **v** approach note indicates to play a fifth away from the target note. Typically this is only used as the last note in a pattern, so that is leads strongly into the next chord. Given the chord progression | Cm7 | Eb , and the pattern 1-2-3-v:
* C-D-E-**Bb** | Eb

**Note:** Sometimes the last bar in the generated line will use a pattern that ends in an approach note. This will result in the line being incomplete, as there is no target note for the approach note reference. In this case, a note will note be inserted, and the final beat in the last bar will be a quarter-note rest. 

Non-Root Patters
-----
Some patterns that do not begin on the root of the chord are also available. If you want WalkingBass to consider these, ensure the "Use non-root patterns" checkbox is ticked. The text box "Non-Roots %" indicates the percentage chance that a non-root pattern will be used. The default value is 30%. 

Non-root patterns are included for both 2-beat and 4-beat patterns. These start on a chord tone - the third or the fifth (and less frequently the 7th). They also contain the approach notes as described above.

For example using the 4beat non-root pattern 3-2-1-a, for all chords in the  Dm | G7 | C  chord progression, would generate the following notes:
* F-E-D-C | B-A-G-F | E-D-C-
Over the Dm chord, F-E-D is played as the third, second and root, followed by a semitone above approach note. Since the target note is the third of the G chord - a B - the approach note is a C. 

The 'v' approach note is still a fifth away from the target note, even though this may not be the root of the target chord. Using the same chord progression (Dm | G7 | C), the and the pattern 3-2-1-**v**:
* F-E-D-F | B-A-G-B | E-D-C-

Adjustments
-----
WalkingBass makes various adjustments to notes to attempt to ensure a smooth, logical walking bass line. 

_The last note_ of chord's pattern may be adjusted up or down to ensure it is not the same as the first note of the next chord's pattern. This ensure's that the distinction between chords is maintained. For example, for the chord progression Dm | G7, and the patterns chosen are 1-2-3-1, and 5-3-1-7 this would result in
* D-E-F-D | D-B-G-F
Note the repeated D at the end of the Dm and the start of the G do not clearly mark the transition from one chord to the next. WalkingBass will adjust the note at the end of the first pattern randomly up or down to ensure a smoother transition
* D-E-F-Eb | D-B-G-F

_Intervals_ may be flipped, to provide some variation, whilst keeping the same pattern. How frequently this occurs is controlled by the Flip Percentage option. WalkingBass is naturally take the note that is the closest interval. For example, the pattern "1-3-5-1" will be generated as an ascending arpeggio. The intervals between each of the notes in the pattern will be smallest they can be. This will ensure a smooth line, however it can easily result in a line that climbs quickly, or becomes frequently boring. As an alternative, WalkingBass may invert any interval of between a (minor) third and sixth.  In the 1-3-5-1 pattern, the third might be played _below_ the root instead of above it. Likewise the final root note might be played below the fifth. 

The _lowest note_ and _range_ options will also naturally adjust notes so they are in the range specified. Out of necessity this can sometimes result in unnatural lines. The lowest note is generally taken as the E below the bass stave. Any notes below this will be raised by an octave, so they are in the playable range. Likewise, any notes above the playable range will be adjusted down an octave. 

Final Thoughts
-----
Given the description above, WalkingBass can do an adequate job of generating a random walking bass line over a given chord progression. Given the randomness, a differnet line will be generated each time. Several attempts might be required before a line is generated that meets the user's needs.  The initial generation may not be perfect, and some notes or bars may well require manual adjustment so they make logical sense. However in the majority of cases WalkingBass should provide a good enough initial line. 

If you have any comments or suggestions for further improvements, please don't hesitate to contact me. 

Phil Kan (pitdadphil@gmail.com)
September, 2022.
