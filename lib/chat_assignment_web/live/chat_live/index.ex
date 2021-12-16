defmodule ChatAssignmentWeb.ChatLive.Index do
  use ChatAssignmentWeb, :live_view

  @pubsub_topic "chat_main"

  import ChatAssignment.Accounts, only: [get_user_by_session_token: 1]

  alias ChatAssignmentWeb.Endpoint
  alias ChatAssignmentWeb.ChatPresence

  alias ChatAssignment.Chat
  alias ChatAssignment.Chat.Message

  @impl true
  def mount(_params, session, socket) do
    # Initial values for assigns
    message_changeset = Chat.change_message(%Message{})
    user = get_user_by_session_token(session["user_token"])
    last_messages = Chat.last_messages()

    # Start PubSub and Presence system for tracking messages and users
    Endpoint.subscribe(@pubsub_topic)

    {:ok, _} =
      ChatPresence.track(self(), @pubsub_topic, session["user_token"], %{
        user: user,
        online_at: inspect(System.system_time(:second))
      })

    {:ok,
     socket
     |> assign(online_users: get_online_users())
     |> assign(messages: last_messages)
     |> assign(message_changeset: message_changeset)
     |> assign(user: user)}
  end

  @impl true
  def handle_event("new_message", %{"message" => message}, socket) do
    {:ok, message_data} =
      message
      |> Map.put("user_id", socket.assigns.user.id)
      |> Chat.create_message()

    message_data = %{message_data | user: socket.assigns.user}

    Endpoint.broadcast(@pubsub_topic, "new_message", message_data)

    {:noreply, socket}
  end

  @impl true
  def handle_info(%{event: "new_message", payload: message}, socket) do
    messages = [message | socket.assigns.messages]

    {:noreply,
     socket
     |> assign(messages: messages)}
  end

  @impl true
  def handle_info(%{event: "presence_diff", payload: _}, socket) do
    {:noreply,
     socket
     |> assign(online_users: get_online_users())}
  end

  defp get_online_users() do
    @pubsub_topic
    |> ChatPresence.list()
    |> Map.keys()
    |> tokens_to_users
  end

  defp tokens_to_users(tokens) do
    Enum.map(tokens, fn token ->
      get_user_by_session_token(token)
    end)
  end
end
