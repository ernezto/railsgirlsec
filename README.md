# Descripción
Contiene los pasos de la guía de creación de la aplicación básica para railsgirls que se indica en este [enlace](http://guides.railsgirls.com/app/)

## Paso 1: Creación del proyecto base en rails
```bash
mkdir projects
cd projects
rails new railsgirls
cd railsgirls
rails server
<CTRL> - c
```

Abrir en un navegador la página [http://localhost:3000](http://localhost:3000)

## Paso 2: Creación del modelo Idea
```bash
rails generate scaffold idea name:string description:text picture:string
bin/rake db:migrate
rails server
<CTRL> - c
```

Abrir en un navegador la página [http://localhost:3000/ideas](http://localhost:3000/ideas)

## Paso 3: Primeros estilos con Twitter Bootstrap
Ver la Guía Paso 3. Design [enlace](http://guides.railsgirls.com/app/)

## Paso 4: Soporte para subir imágenes
Ver la Guía Paso 4. Adding picture uploads [enlace](http://guides.railsgirls.com/app/)
