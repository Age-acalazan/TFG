from PIL import Image

# Cargar la imagen
img = Image.open('diamonds.png')
width, height = img.size

# Calcular el ancho de cada sección
section_width = width // 14

# Dividir y guardar cada sección
for i in range(14):
    # Calcular las coordenadas de corte
    left = i * section_width
    right = (i + 1) * section_width if i < 13 else width  # La última sección incluye cualquier pixel restante
    
    # Recortar la sección
    section = img.crop((left, 0, right, height))
    
    # Guardar con el nombre d1, d2, ..., d14
    section.save(f'{i+1}d.png')
    print(f'Guardada sección c{i+1}.png')

print('¡Proceso completado!')
