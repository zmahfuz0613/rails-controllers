# ![](https://ga-dash.s3.amazonaws.com/production/assets/logo-9f88ae6c9c3871690e33280fcf557f33.png)  SOFTWARE ENGINEERING IMMERSIVE

# Rails Controllers

## setup

1. clone
2. `bundle`
3. `rails db:setup`

## Objectives

After this lesson, we should have knowledge of the following topics:

- Controller Structure
- Private Method Abstraction
- `before_action`
- Strong Params
- Error Handling

## Controller Structure

Let's first take a look at a very basic controller setup:

```ruby

class UsersController < ApplicationController

  # GET /users
  def index
    @users = User.all

    render json: @users
  end

  # GET /users/1
  def show
    @user = User.find(params[:id])

    render json: @user
  end

  # POST /users
  def create
    @user = User.create(params)

    render json: @user
  end

  # PUT /users/1
  def update
    @user = User.find(params[:id])
    @user.update(params)

    render json: @user
  end

  # DELETE /users/1
  def destroy
    @user = User.find(params[:id])

    @user.destroy
  end

end

```


These are basic setups for the five default controller actions. This could get us by but we are not limited to just these five methods. We can customize this any way we want to. If we need a new separate method that breaks outside of the typical RESTful routing pattern, we are free to do this. We would also need a custom route to point to this controller action as well.

Example:

`/app/controllers/users_controller.rb`

```ruby
class UsersController < ApplicationController
  ...
  def easter_egg
    render json: "this is a custom response" 
  end
  ...
end
```

`/config/routes.rb`

```ruby

Rails.application.routes.draw do
  ...
  get '/our-custom-route', to: 'users#easter_egg'
  ...
end
```

For most situations this is not needed but we can leverage this to get some added functionality to our api. For instance, we will be seeing custom methods when we implement authentication and authorization.

### We do:

Let's walk through creating a custom method and route that simply finds a random user from the database. We can call the method and route "friend suggestion"


## Private Method Abstraction/Before Action

Within our five main methods for CRUD, We see repetition. In `show`, `update` and `delete`, we start off each method with the same line: `@user = User.find(params[:id])`. We could pull this line out into it's own method called `set_user`

```ruby
class UsersController < ApplicationController
  ...
  private

  def set_user
    @user = User.find(params[:id])
  end
end
```

Now we could use the `set_user` method in each of our routes that use the `:id` param and maybe that would save us a few characters but rails has something for us. The `before_action` key work let's us call a method before several actions all in one line.

Example:

```ruby
class UsersController < ApplicationController
  before_action :set_user, only: [:show, :update, :destroy]
  ...
end
```

This will call the `set_user` method whenever the `show`, `update` and `destroy` are called. This is an easy way for us clean up some code in our controller.

## [Strong Params](https://edgeapi.rubyonrails.org/classes/ActionController/StrongParameters.html)

Rails has a security feature built in called `Strong Params`. When using this interface, each request will be sent through a predefined `raise`/`rescue` block. If the correct parameters are not provided, our server will automatically send a "400 bad request" response for us.

Example:

```ruby
class UsersController < ApplicationController
  ...
  private

  def user_params
    params.require(:user).permit(:name, :age)
  end
end

```

The `.permit` method is saying that we will only except the `name` and `age` values from a request body. Additionally the `.require` is saying that any data in our request body that is not nested in a JSON object under the key of `user` will be ignored. This gives us fine tuned control over what we our api excepts.

Example request body:

```JSON
{
  "user": {
    "name": "CoolCat88",
    "age": 31
  }
}
```

Now if we forget to nest our data under the `user` key, rails will do it's best to coerce our request body into a nested object for us.

<details>
<summary>you can change this setting</summary>

You can change this default setting if you want to. It can be found in `/config/initializers/wrap_parameters.rb`

</details>

> Why is it important to restrict what data the server excepts? What is the point of `.require` if rails will coerce our data into the correct object anyways?

## Error Handling

For our `create` and `update`, we accept in data from the request body typically provided by the end user. This causes the potential to throw errors that we cannot predict. We can however account for it. We could wrap our whole method block in `begin` and `rescue`, however Active Record has some built in functionality which works nicely with vanilla ruby.

The `.save` and `.update` methods will return a falsey value if the error while attempting to add entries into the database. We can use this in a `if`/`else` conditional statement.

Example:

```ruby
class UsersController < ApplicationController
  ...
  # POST /users
  def create
    @user = User.new(user_params)

    if @user.save
      render json: @user, status: :created
    else
      render json: @user.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /users/1
  def update
    if @user.update(user_params)
      render json: @user
    else
      render json: @user.errors, status: :unprocessable_entity
    end
  end
  ...
end
```

Here is a list of available status codes that we can send along with and `render` statement:

<details>
<summary>Rails status code symbols</summary>

1xx Informational
 - 100 :continue
 - 101 :switching_protocols
 - 102 :processing

2xx Success
 - 200 :ok
 - 201 :created
 - 202 :accepted
 - 203 :non_authoritative_information
 - 204 :no_content
 - 205 :reset_content
 - 206 :partial_content
 - 207 :multi_status
 - 226 :im_used

3xx Redirection
 - 300 :multiple_choices
 - 301 :moved_permanently
 - 302 :found
 - 303 :see_other
 - 304 :not_modified
 - 305 :use_proxy
 - 307 :temporary_redirect

4xx Client Error
 - 400 :bad_request
 - 401 :unauthorized
 - 402 :payment_required
 - 403 :forbidden
 - 404 :not_found
 - 405 :method_not_allowed
 - 406 :not_acceptable
 - 407 :proxy_authentication_required
 - 408 :request_timeout
 - 409 :conflict
 - 410 :gone
 - 411 :length_required
 - 412 :precondition_failed
 - 413 :request_entity_too_large
 - 414 :request_uri_too_long
 - 415 :unsupported_media_type
 - 416 :requested_range_not_satisfiable
 - 417 :expectation_failed
 - 422 :unprocessable_entity
 - 423 :locked
 - 424 :failed_dependency
 - 426 :upgrade_required

5xx Server Error
 - 500 :internal_server_error
 - 501 :not_implemented
 - 502 :bad_gateway
 - 503 :service_unavailable
 - 504 :gateway_timeout
 - 505 :http_version_not_supported
 - 507 :insufficient_storage
 - 510 :not_extended

</details>


## Fully Functional Controller

At this point, we've stacked our `user` controller with a lot of functionality. Here is what it should look like at this point:

<details>
<summary>users_controller.rb</summary>

```ruby
class UsersController < ApplicationController
  before_action :set_user, only: [:show, :update, :destroy]

  # GET /users
  def index
    @users = User.all

    render json: @users
  end

  # GET /users/1
  def show
    render json: @user
  end

  # POST /users
  def create
    @user = User.new(user_params)

    if @user.save
      render json: @user, status: :created
    else
      render json: @user.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /users/1
  def update
    if @user.update(user_params)
      render json: @user
    else
      render json: @user.errors, status: :unprocessable_entity
    end
  end

  # DELETE /users/1
  def destroy
    @user.destroy
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_user
      @user = User.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def user_params
      params.require(:user).permit(:name, :age)
    end
end
```

</details>

## Nested associations

feel comfortable with rails controllers? Check out [nested associations](nestedAssociations.md)
