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
Para permitir la edición solo a los propietarios de las ideas se debe editar el controlador app/controllers/ideas_controller.rb. Reemplazar la definición del método edit con el siguiente código

```ruby
def edit
  @idea = current_user.ideas.find_by_id(params[:id])
  if @idea.nil?
  redirect_to ideas_path, flash: {alert: 'No existe la idea que desea modificar'}
  end
end
```

En este caso estamos cargando la idea con el identificador que se envía como parte del parámetro de la URL desde la lista de las ideas del usuario autenticado usando el helper de 'devise' current_user. Por tanto si la idea no se encuentra en la lista de las ideas que fueron creadas por el usuario autenticado se redirecciona a la página del listado de ideas mostrando un mensaje de alerta.

Ahora al crear una nueva idea debemos asignarle el usuario actual como propietario, para ello modificamos el metodo create y colocamos la siguiente línea 

```ruby
@idea.user = current_user
```

justo debajo del siguiente código:

```ruby
...
def create
    @idea = Idea.new(idea_params)
...
```

A continuación agregamos la siguiente línea justo debajo de la definción del método update

```ruby
...
def update
  @idea = current_user.ideas.find(params[:id])
...
```

Para finalizar modificamos el html contenido en la vista del listado app/views/ideas/index.html.erb para solo mostrar los enlaces de editar y eliminar solo si el usuario es el propietario de la idea

```html
<% if current_user.ideas.include? idea %>
<td><%= link_to 'Edit', edit_idea_path(idea) %></td>
<td><%= link_to 'Destroy', idea, method: :delete, data: { confirm: 'Are you sure?' } %></td>
<% else %>
<td></td>
<td></td>
<% end %>
```

## Paso 10: Mejorando el html y el css de la interfaz de usuario
Editamos la hoja de estilos principal (app/assets/stylesheets/application.css) para disminuir la separación entre el cuerpo del html y la barra superior de navegación.

```css
donde dice:
body { padding-top: 100px; }
...
sustituir por:
body { padding-top: 60px; }
...
```

Eliminamos la hoja de estilos ubicada en archivo app/assets/stylesheets/scaffolds.scss para que no sobreescriba nuestros estilos propios

```bash
rm -f app/assets/stylesheets/scaffolds.scss
```

Para modificar las vistas necesitamos tener nuestras propias copias en nuestro proyecto local, para ello ejecutamos el siguiente comando

```bash
rails g  devise:views
rm -rf app/views/devise/confirmations app/views/devise/mailer app/views/devise/shared app/views/devise/unlocks
```

Con esto se han copiado todas las vistas de devise en el proyecto local y eliminamos aquellas que no deseamos modificar por el momento. Ahora procedemos con la actualizacion de dichas vistas.

Primero sustitimos la vista para cambiar las credenciales app/views/devise/passwords/edit.html.erb con el siguiente contenido:
```html
<h2>Change your password</h2>

<div class="col-md-5">
  <%= form_for(resource, as: resource_name, url: password_path(resource_name), html: { method: :put }) do |f| %>
    <%= devise_error_messages! %>
    <%= f.hidden_field :reset_password_token %>

    <div class="form-group">
      <%= f.label :password, "New password" %><br />
      <% if @minimum_password_length %>
      <em>(<%= @minimum_password_length %> characters minimum)</em>
      <% end %>
      <%= f.password_field :password, autofocus: true, autocomplete: "off", class: 'form-control', placeholder: 'Contraseña' %>
    </div>

    <div class="form-group">
      <%= f.label :password_confirmation, "Confirm new password" %>
      <%= f.password_field :password_confirmation, autocomplete: "off", class: 'form-control', placeholder: 'Contraseña' %>
    </div>

    <%= f.submit "Change my password", class: 'btn btn-default' %>
  <% end %>

  <br />
  <%= render "devise/shared/links" %>
</div>
```

Note el uso de los estilos de bootstrap en las etiquetas html div y en los generadores de rails, tales como: `<div class="col-md-5">`, `<div class="form-group">`, `class: 'btn btn-default'`, `class: 'form-control'`

Luego sustituimos el contenido de la vista para recordar las credenciales app/views/devise/passwords/new.html.erb con el siguiente contenido:

```html
<h2>Forgot your password?</h2>

<div class="col-md-5">
  <%= form_for(resource, as: resource_name, url: password_path(resource_name), html: { method: :post }) do |f| %>
    <%= devise_error_messages! %>

    <div class="form-group">
      <%= f.label :email %>
      <%= f.email_field :email, autofocus: true, class: 'form-control', placeholder: 'Email' %>
    </div>

    <%= f.submit "Send me reset password instructions", class: 'btn btn-default' %>
  <% end %>

  <br />
  <%= render "devise/shared/links" %>
</div>
```

Seguimos sustituyendo las vistas de devise como sigue a continuación:

archivo: app/views/devise/registrations/edit.html.erb

```html
<h2>Edit <%= resource_name.to_s.humanize %></h2>

<div class="col-md-5">
  <%= form_for(resource, as: resource_name, url: registration_path(resource_name), html: { method: :put }) do |f| %>
    <%= devise_error_messages! %>

    <div class="form-group">
      <%= f.label :email %>
      <%= f.email_field :email, autofocus: true, class: 'form-control', placeholder: 'Email' %>
    </div>

    <% if devise_mapping.confirmable? && resource.pending_reconfirmation? %>
      <div>Currently waiting confirmation for: <%= resource.unconfirmed_email %></div>
    <% end %>

    <div class="form-group">
      <%= f.label :password %> <i>(leave blank if you don't want to change it)</i>
      <%= f.password_field :password, autocomplete: "off", class: 'form-control', placeholder: 'Contraseña' %>
    </div>

    <div class="form-group">
      <%= f.label :password_confirmation %>
      <%= f.password_field :password_confirmation, autocomplete: "off", class: 'form-control', placeholder: 'Contraseña' %>
    </div>

    <div class="form-group">
      <%= f.label :current_password %> <i>(we need your current password to confirm your changes)</i>
      <%= f.password_field :current_password, autocomplete: "off", class: 'form-control', placeholder: 'Contraseña actual' %>
    </div>

    <%= f.submit "Update", class: 'btn btn-default' %>
    <%= link_to 'Back', ideas_path, class: 'btn btn-danger' %>
  <% end %>
</div>
```

archivo: app/views/devise/registrations/new.html.erb|

```html
<h2>Sign up</h2>

<div class="col-md-5">
  <%= form_for(resource, as: resource_name, url: registration_path(resource_name)) do |f| %>
    <%= devise_error_messages! %>

    <div class="form-group">
      <%= f.label :email %>
      <%= f.email_field :email, autofocus: true, class: 'form-control', placeholder: 'Email' %>
    </div>

    <div class="form-group">
      <%= f.label :password %>
      <% if @minimum_password_length %>
      <em>(<%= @minimum_password_length %> characters minimum)</em>
      <% end %><br />
      <%= f.password_field :password, autocomplete: "off", class: 'form-control', placeholder: 'Contraseña' %>
    </div>

    <div class="form-group">
      <%= f.label :password_confirmation %><br />
      <%= f.password_field :password_confirmation, autocomplete: "off", class: 'form-control', placeholder: 'Confirmación' %>
    </div>

    <%= f.submit "Registrarme", class: 'btn btn-default' %>
    <%= link_to 'Atrás', ideas_path, class: 'btn btn-danger' %>
  <% end %>
</div>
```

archivo: app/views/devise/sessions/new.html.erb

```html
<h2>Log in</h2>

<div class="col-md-5">
  <%= form_for(resource, as: resource_name, url: session_path(resource_name)) do |f| %>
    <div class="form-group">
      <%= f.label :email %>
      <%= f.email_field :email, autofocus: true, class: 'form-control', placeholder: 'Email' %>
    </div>

    <div class="form-group">
      <%= f.label :password %>
      <%= f.password_field :password, autocomplete: "off", class: 'form-control', placeholder: 'Contraseña' %>
    </div>

    <% if devise_mapping.rememberable? -%>
      <div class="form-group">
        <%= f.check_box :remember_me %>
        <%= f.label :remember_me %>
      </div>
    <% end -%>

    <%= f.submit "Log in", class: 'btn btn-default' %>
  <% end %>
  <br />
  <%= render "devise/shared/links" %>
</div>
```

archivo: app/views/ideas/_form.html.erb

```html
<div class="col-md-5">
  <%= form_for(@idea, html: {role: 'form'}) do |f| %>
    <% if @idea.errors.any? %>
      <div id="error_explanation">
        <h2><%= pluralize(@idea.errors.count, "error") %> prohibited this idea from being saved:</h2>

        <ul>
        <% @idea.errors.full_messages.each do |message| %>
          <li><%= message %></li>
        <% end %>
        </ul>
      </div>
    <% end %>

    <div class="form-group">
      <%= f.label :name %>
      <%= f.text_field :name, class: 'form-control', placeholder: 'Nombre' %>
    </div>
    <div class="form-group">
      <%= f.label :description %>
      <%= f.text_area :description, class: 'form-control', placeholder: 'Descripción' %>
    </div>
    <div class="form-group">
      <%= f.label :picture %>
      <%= f.file_field :picture %>
    </div>

    <%= f.submit class: 'btn btn-default' %>
    <%= link_to 'Back', ideas_path, class: 'btn btn-danger' %>
  <% end %>
</div>
```

archivo: app/views/ideas/edit.html.erb

sustituimos la línea que dice
```html
<h1>Editing Idea</h1>
```

por:
```html
<h1>Edit - <%= @idea.name %></h1>
```

y eliminamos los siguientes dos enlaces que aparecen al final del archivo:
```html
<%= link_to 'Show', @idea %> |
<%= link_to 'Back', ideas_path %>
```

archivo: app/views/ideas/index.html.erb

sustituimos:
```html
<table>
  <thead>
    <tr>
      <th>Name</th>
      <th>Description</th>
      <th>Picture</th>
      <th colspan="3"></th>
    </tr>
  </thead>

  <tbody>
    <% @ideas.each do |idea| %>
      <tr>
        <td><%= idea.name %></td>
        <td><%= idea.description %></td>
        <td><%= idea.picture %></td>
        <td><%= link_to 'Show', idea %></td>
        <% if current_user.ideas.include? idea %>
          <td><%= link_to 'Edit', edit_idea_path(idea) %></td>
          <td><%= link_to 'Destroy', idea, method: :delete, data: { confirm: 'Are you sure?' } %></td>
        <% else %>
          <td></td>
          <td></td>
        <% end %>
      </tr>
     <% end %>
  </tbody>
</table>

<br>

<%= link_to 'New Idea', new_idea_path %>

```
por:
```html
<% @ideas.in_groups_of(3) do |group| %>
  <div class="row">
    <% group.compact.each do |idea| %>
      <div class="col-md-4">
        <%= image_tag idea.picture_url, class: 'img-thumbnail' if idea.picture.present?%>
        <h4><%= link_to idea.name, idea %></h4>
        <%= idea.description %>
      </div>
     <% end %>
  </div>
<% end %>
```

archivo: app/views/ideas/new.html.erb
Eliminamos el siguiente enlace que aparece al final:

```html
<%= link_to 'Back', ideas_path %>
```

archivo: app/views/ideas/show.html.erb

sustituimos:
```html
<p>
  <strong>Name:</strong>
  <%= @idea.name %>
</p>

<p>
  <strong>Description:</strong>
  <%= @idea.description %>
</p>

<p>
  <strong>Picture:</strong>
  <%= image_tag(@idea.picture_url, :width => 600) if @idea.picture.present? %>
</p>

<%= link_to 'Edit', edit_idea_path(@idea) %> |
<%= link_to 'Back', ideas_path %>
```

por:
```html
<p id="notice"><%= notice %></p>

<div class="row">
  <div class="col-md-9">
    <%= image_tag(@idea.picture_url, width: '100%') if @idea.picture.present? %>
  </div>

  <div class="col-md-3">
    <p><b>Name: </b><%= @idea.name %></p>
    <p><b>Description: </b><%= @idea.description %></p>
    <p>
      <% if current_user.ideas.include? @idea %>
        <%= link_to 'Edit', edit_idea_path(@idea) %> |
        <%= link_to 'Destroy', @idea, data: { confirm: 'Are you sure?' }, method: :delete %> |
      <% end %>
      <%= link_to 'Back', ideas_path %>
    </p>
  </div>
</div>
```

En la plantilla principal app/views/layouts/application.html.erb agregamos el siguiente código justo debajo de las líneas:

```html
<li class="<%= 'active' if current_page?(pages_info_path) %>">
 <%= link_to '¿Quién soy?', pages_info_path %>
</li>
```

agregar:
```html
<li class="<%= 'active' if current_page?(new_idea_path) %>">
  <%= link_to 'Nueva Idea', new_idea_path %>
</li>
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

## Paso 12: Agregando sistema de votación
Abrir el archivo Gemfile y agregar la gema

```ruby
gem 'acts_as_votable', '~> 0.10.0'
```

Ejecutar en consola
```bash
bundle install
rails generate acts_as_votable:migration
rake db:migrate
```

Editar el archivo config/routes.rb sustituyendo la línea `resources :ideas` por:

```ruby
 resources :ideas do
   member do
     put 'like', to: 'ideas#upvote'
     put 'dislike', to: 'ideas#downvote'
   end
 end
```

Editar el archivo app/models/user.rb agregando la siguiente línea antes de 'end':

```ruby
acts_as_voter
```

Editar el archivo app/models/idea.rb agregando la siguiente línea antes de 'end':

```ruby
acts_as_votable
```

Editar el archivo app/assets/stylesheets/application.css agregando los siguientes estilos al final del archivo

```css
.votes-container a{
  text-decoration: none !important;
  color: #aaa;
}
.blue{
  color: #1c6fec;
  font-weight: bold;
}
.red{
  color: #e9252b;
  font-weight: bold;
}

.grid-image-container{
  height: 150px;
}

.grid-image{
  width: 150px;
  max-height: 150px;
}
```

Editar el archivo app/controllers/ideas_controller.rb agregando los siguientes metodos:

```ruby
  def upvote
    @idea = Idea.find(params[:id])
    @idea.upvote_by current_user
    redirect_to ideas_path
  end

  def downvote
    @idea = Idea.find(params[:id])
    @idea.downvote_by current_user
    redirect_to ideas_path
  end
```

Editar la vista del listado de ideas app/views/ideas/index.html.erb y sustituir:

```html
<% @ideas.in_groups_of(3) do |group| %>
   <div class="row">
     <% group.compact.each do |idea| %>
      <div class="col-md-4">
        <%= image_tag idea.picture_url, class: 'img-thumbnail' if idea.picture.present?%>
        <h4><%= link_to idea.name, idea %></h4>
        <%= idea.description %>
```
Por:

```html
+<% @ideas.in_groups_of(6) do |group| %>
   <div class="row">
     <% group.compact.each do |idea| %>
+      <div class="col-md-2">
+        <%= link_to idea do %>
+          <div class="grid-image-container">
+            <%= image_tag idea.picture_url, class: 'img-thumbnail grid-image' if idea.picture.present?%>
+          </div>
+        <% end %>
+        <h4>
+          <%= link_to idea.name, idea %>
+          <small class="pull-right votes-container">
+            <%= link_to like_idea_path(idea), method: :put do %>
+              <span class="<%= current_user.voted_up_on?(idea) ? "selected blue" : "" %> votes">
+                <%= idea.get_upvotes.size %>
+                <span class="glyphicon glyphicon-arrow-up"></span>
+              </span>
+            <% end %>
+            <%= link_to dislike_idea_path(idea), method: :put do %>
+              <span class="<%= current_user.voted_down_on?(idea) ? "red" : "" %> votes">
+                <%= idea.get_downvotes.size %>
+                <span class="glyphicon glyphicon-arrow-down"></span>
+              </span>
+            <% end %>
+          </small>
+        </h4>
+        <p>
+          <%= idea.description %>
+        </p>
```
