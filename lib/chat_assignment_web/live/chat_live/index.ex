defmodule ChatAssignmentWeb.ChatLive.Index do
  use ChatAssignmentWeb, :live_view

  import ChatAssignment.Accounts, only: [get_user_by_session_token: 1]

  alias ChatAssignment.Chat
  alias ChatAssignment.Chat.Message

  @impl true
  def mount(_params, session, socket) do
    message_changeset = Chat.change_message(%Message{})
    user = get_user_by_session_token(session["user_token"])
    last_messages = Chat.last_messages
    {:ok,
    socket
    |> assign(messages: last_messages)
    |> assign(message_changeset: message_changeset)
    |> assign(user: user)
  }
  end

  @impl true
  def handle_event("new_message", %{"message" => message}, socket) do

    {:ok, _message_struct} =
      message
      |> Map.put("user_id", socket.assigns.user.id)
      |> Chat.create_message

    {:noreply, socket}
  end

end
