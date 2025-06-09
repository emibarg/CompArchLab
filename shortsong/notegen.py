# Ya definidos
base_frequencies = {
    "C4": 261.8, "C#4": 277.0, "D4": 294.3, "E4": 330.9,
    "F4": 348.1, "G4": 391.0, "A4": 442.0, "B4": 493.5,

    "C5": 523.3, "C#5": 554.4, "D5": 587.3, "D#5": 622.3,
    "E5": 659.3, "F5": 698.5, "F#5": 739.9, "G5": 783.9,
    "G#5": 830.6, "A5": 880.0, "A#5": 932.3, "B5": 987.8,

    "rest": 1,
}

base_values = {
    "C4": 11500, "C#4": 10600, "D4": 10230, "E4": 9100,
    "F4": 8650, "G4": 7700, "A4": 6800, "B4": 6100,

    "C5": 5740, "C#5": 5450, "D5": 5140, "D#5": 4850,
    "E5": 4550, "F5": 4320, "F#5": 4075, "G5": 3830,
    "G#5": 3633, "A5": 3428, "A#5": 3225, "B5": 3050,

    "rest": 100000,
}

duration_to_seconds = {
    "seminegra": 0.1875,
    "negra": 0.375,
    "negra con punto": 0.5625,
    "blanca": 0.75,
    "blanca con punto": 0.9375,
    "blanca completa": 1.5,
}

def generate_quad(note_str, duration_label):
    if duration_label not in duration_to_seconds:
        return f"// Duración desconocida: {duration_label}"

    if note_str.lower() == "rest":
        return f".quad 1, 1000    // rest, {duration_label}"

    if note_str not in base_frequencies or note_str not in base_values:
        return f"// Nota desconocida: {note_str}"

    freq = base_frequencies[note_str]
    value = base_values[note_str]
    duration = round(freq * duration_to_seconds[duration_label])

    return f".quad {value}, {duration}    // {note_str}, {duration_label}"

# 📝 Aquí va tu lista input_notes (ya la tienes en tu mensaje)
input_notes = [
    ('F4', 'seminegra'), ('D4', 'seminegra'), ('A4', 'seminegra'), ('D4', 'seminegra'),
    ('F4', 'seminegra'), ('D4', 'seminegra'), ('A4', 'seminegra'), ('D4', 'seminegra'),
    ('F4', 'seminegra'), ('C4', 'seminegra'), ('A4', 'seminegra'), ('D4', 'seminegra'),
    ('F4', 'seminegra'), ('C4', 'seminegra'), ('A4', 'seminegra'), ('D4', 'seminegra'),
    ('E4', 'seminegra'), ('C#4', 'seminegra'), ('A4', 'seminegra'), ('D4', 'seminegra'),
    ('E4', 'seminegra'), ('C4', 'seminegra'), ('A4', 'seminegra'), ('D4', 'seminegra'),
    ('E4', 'seminegra'), ('C#4', 'seminegra'), ('A4', 'seminegra'), ('D4', 'seminegra'),
    ('E4', 'seminegra'), ('C4', 'seminegra'), ('A4', 'seminegra'), ('D4', 'seminegra'),
    ('D5', 'blanca con punto'), ('E5', 'negra'),
    ('F5', 'blanca completa'),
    ('A5', 'negra con punto'), ('G5', 'seminegra'), ('rest','seminegra'), ('G5', 'negra'), ('A5', 'negra'),
    ('C5', 'blanca completa'),
    ('D5', 'blanca con punto'), ('E5', 'negra'),
    ('F5', 'blanca'), ('E5', 'blanca'), ('G5', 'blanca'), ('A5', 'blanca'),
    ('G5', 'blanca'), ('F5', 'blanca'),('rest','seminegra'),
    ('F5', 'negra'),('rest','seminegra'), ('F5', 'negra'),('rest','seminegra'), ('F5', 'negra'),('rest','seminegra'), ('F5', 'negra'),
    ('A5', 'negra'),('rest','seminegra'), ('A5', 'negra'), ('G5', 'negra'), ('F5', 'negra'), ('rest','seminegra'),
    ('F5', 'negra'), ('A5', 'negra'),('rest','seminegra'), ('A5', 'negra'),('rest','seminegra'), ('A5', 'negra'),
    ('G5', 'negra'), ('A5', 'negra'), ('G5', 'negra'), ('F5', 'negra'),
]
for note, dur in input_notes:
    print(generate_quad(note, dur))
