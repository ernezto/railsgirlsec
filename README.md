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

## Paso 5: Modificación de la ruta raíz
Editar el archivo config/routes.rb agregando la siguiente línea al principio
```ruby
root :to => redirect('/ideas')
```

## Paso 6: Creando página estática de información
Ejecutar el siguiente comando en la consola

```bash
rails generate controller pages info
```
Verificar que en el archivo de rutas se encuentre la línea

```ruby
get "pages/info"
```

## Paso 7: Creando autenticación básica
Ver la Guía 5. Add authentication with devise [enlace](http://guides.railsgirls.com/devise/)

## Paso 8: Asignando usuarios al modelo de ideas
Editar el archivo app/models/idea.rb y agregar la relación con usuario. (note el uso del singular en el nombre del modelo)

```ruby
belongs_to :user
```

Editar el archivo app/models/user.rb y agregar la relación con usuario (note el uso del plurar en el nombre del modelo)

```ruby
has_many :ideas
```

Escribir en la consola

```bash
rails g  migration AddUserToIdeas user_id:integer
rake db:migrate
```

Editar el controlador de ideas app/controllers/ideas_controller.rb y agregar lo siguiente en el metodo create justo debado de la línea @idea = Idea.new(idea_params)

```ruby
@idea.user = current_user
```

## Paso 9: Permitiendo la modificación de las ideas solo a sus propietarios

## Paso 10: Mejorando el html y el css de la interfaz de usuario
Para modificar las vistas de devise ejecutar el comando

```bash
rails g  devise:views
rm -rf app/views/devise/confirmations app/views/devise/mailer app/views/devise/shared app/views/devise/unlocks
```

## Paso 11: Agregando comentarios a las ideas
Abrir el archivo Gemfile y agregar la gema

```ruby
gem 'commontator', '~> 4.10.0'
```

```bash
bundle install
rake commontator:install
rake db:migrate
```

Editar el archivo config/initializers/commontator.rb cambiando la línea 39 donde dice

```ruby
config.user_name_proc = lambda { |user| I18n.t('commontator.anonymous') }
```

Por:

```ruby
config.user_name_proc = lambda { |user| user.email }
```

Editar el archivo config/routes.rb agregando la siguiente línea antes de 'end':

```ruby
mount Commontator::Engine => '/commontator'
```

Editar el archivo app/models/user.rb agregando la siguiente línea antes de 'end':

```ruby
acts_as_commontator
```

Editar el archivo app/models/idea.rb agregando la siguiente línea antes de 'end':

```ruby
acts_as_commontable
```

Editar el archivo app/views/ideas/show.html.erb agregando la siguiente al final del archivo

```ruby
<%= commontator_thread(@idea) %>
```

Editar el archivo app/controllers/ideas_controller.rb agregando la siguiente dentro del método show

```ruby
commontator_thread_show(@idea)
```
