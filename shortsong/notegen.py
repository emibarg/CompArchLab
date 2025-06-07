# Note frequency table based on your .quad values
note_freqs = {
    "C": 1309,  # DO (261.8 Hz)
    "D": 1469,  # RE (294.3 Hz)
    "E": 1649,  # MI (330.9 Hz)
    "F": 1747,  # FA (348.1 Hz)
    "G": 1960,  # SOL (391 Hz)
    "A": 2200,  # LA (442 Hz)
    "B": 2470,  # SI (493.5 Hz)
    "C#": 1380,  # Approximate frequency; adjust if needed
    "rest": 500,  # Special case for rest (only second column matters)
}


# Function to convert melody list to .quad lines
def print_melody(melody):
    print(".align 3")
    print("melody:")
    for note, duration in melody:
        if note.lower() == "rest":
            print(f"    .quad 1, {note_freqs['rest']}    // rest")
        elif note in note_freqs:
            half_period = int(note_freqs[note] * duration)
            print(f"    .quad {half_period}, {note_freqs[note]}    // {note}")
        else:
            print(f"    // Unknown note '{note}'")


# Example usage
melody_data = [
    ("D", 1),
    ("rest", 1),
    ("D", 1),
    ("E", 1),
    ("F", 1),
    ("A", 1),
    ("G", 1),
    ("A", 1),
    ("C", 1),
    ("D", 1),
    ("E", 1),
    ("F", 1),
    ("E", 1),
    ("G", 1),
    ("A", 1),
    ("G", 1),
    ("F", 1),
    ("rest", 1),
    ("F", 1),
    ("rest", 1),
    ("F", 1),
    ("rest", 1),
    ("F", 1),
    ("A", 1),
    ("rest", 1),
    ("A", 1),
    ("G", 1),
    ("F", 1),
    ("A", 1),
    ("rest", 1),
    ("A", 1),
    ("rest", 1),
    ("A", 1),
    ("G", 1),
    ("A", 1),
    ("G", 1),
    ("F", 1),
    ("rest", 1),
    ("F", 1),
    ("rest", 1),
    ("F", 1),
    ("rest", 1),
    ("F", 1),
    ("A", 1),
    ("rest", 1),
    ("A", 1),
    ("G", 1),
    ("F", 1),
    ("A", 1),
    ("rest", 1),
    ("A", 1),
    ("rest", 1),
    ("A", 1),
    ("C#", 1),
    ("rest", 1),
    ("C#", 1),
    ("rest", 1),
    ("C#", 1),
    ("F", 1),
    ("rest", 1),
    ("F", 1),
    ("rest", 1),
    ("F", 1),
    ("A", 1),
    ("rest", 1),
    ("A", 1),
    ("G", 1),
    ("F", 1),
    ("A", 1),
    ("rest", 1),
    ("A", 1),
    ("rest", 1),
    ("A", 1),
    ("G", 1),
    ("C", 1),
    ("G", 1),
    ("C#", 1),
    ("D", 1),
]

print_melody(melody_data)
