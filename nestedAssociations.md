## Nested Associations

This controller right now works great for a single resource. But this raises the question, "How do we address associated resources?" Let's first lake a look at a route for a nested resource of users and posts:

```ruby
  get '/users/:user_id/posts', to: 'posts#index'
```

a couple things to note here:

1. By default, rails points to the controller for the nested resource. In this case, it would look to the posts controller. All of our logic should live here for our association.
2. The `id` for the parent resource is called `user_id`. We can use this in our logic.

### `includes`

For our `index` method, instead of grabbing all of the posts, we need to grab posts for a specific user. It would end up looking something like this:

`posts_controller.rb`

```ruby 
def index
  @user = User.find(params[:user_id])

  render json: @user.posts
end
```

Now if we wanted to, we could easily return the user and their posts using the `include` key word:

```ruby 
def index
  @user = User.find(params[:user_id])

  render json: @user, include: :posts
end
```

This will provide us with the user but the user will have a `posts` key in the json object. It end up responding with json that looks like this:

```
{
  id: 1,
  name: "CoolCat88",
  age: 31,
  posts: [
    {some post data},
    {more post data},
    ...
  ]
  created_at: "2020-03-30 20:48:16,
  updated_at: "2020-03-30 20:48:16
}
```

## We Do:

let's walk through the rest of the posts_controller.rb methods and update them to include nested functionality.

## Multi-route Controller Methods

This is great for getting all of the posts for a user but doesn't help us if we still want all of the posts. Our `show` method no longer haas the functionality of getting all posts nor do we have a route for that.

Let's add another route to get all posts:

```ruby
  get '/users/:user_id/posts', to: 'posts#index'
  get '/posts', to: 'posts#index'
```

This gives us a new route but it also points to the same controller and method. We will need to add to the `show` method to accommodate both routes. This is where we can leverage the fact that the nested route has a `user_id` param and the other route does not.

```ruby 
def index
  if params[:user_id]
    @user = User.find(params[:user_id])

    render json: @user, include: :posts
  else
    @posts = Post.all

    render json: @posts
  end
end
```

Now we have functionality for both routes in one controller method.

> Which other methods would we also want this nested functionality?
