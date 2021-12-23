defmodule ChatAssignmentWeb.ChatLiveTest do
  use ChatAssignmentWeb.ConnCase

  alias ChatAssignment.Chat.Message
  alias ChatAssignmentWeb.Endpoint

  import Phoenix.LiveViewTest
  import ChatAssignment.AccountsFixtures

  @valid_message_attrs %{content: "Hello! My number is #{System.unique_integer()}"}
  @chat_path Routes.chat_index_path(ChatAssignmentWeb.Endpoint, :index)
  @pubsub_topic ChatAssignmentWeb.ChatLive.Index.get_topic()

  defp added_logged_in_user(%{conn: conn}) do
    user = confirmed_user_fixture()
    conn = log_in_user(conn, user)
    %{user: user, conn: conn}
  end

  test "Redirect unauthorized", %{conn: conn} do
    conn = get(conn, @chat_path)
    assert redirected_to(conn) == Routes.user_session_path(conn, :new)
  end

  describe "Chat" do
    setup [:added_logged_in_user]

    test "New message saved in db", %{conn: conn} do
      {:ok, view, _html} = live(conn, @chat_path)

      view
      |> form("#message-form", message: @valid_message_attrs)
      |> render_submit()

      assert ChatAssignment.Repo.get_by(Message, content: @valid_message_attrs.content)
    end

    test "Broadcasted message appears in the view", %{conn: conn, user: user} do
      {:ok, view, _html} = live(conn, @chat_path)

      {:ok, message_data} =
        ChatAssignment.Chat.create_message(%Message{user_id: user.id}, @valid_message_attrs)

      refute render_element(view, "#chat-container") =~ "#{@valid_message_attrs.content}"

      message_data = %Message{message_data | user: user}
      Endpoint.broadcast(@pubsub_topic, "new_message", message_data)

      assert render_element(view, "#chat-container") =~ "#{@valid_message_attrs.content}"
    end

    @tag :capture_log
    test "Invalid message raises an error", %{conn: conn} do
      {:ok, view, _html} = live(conn, @chat_path)

      Process.flag(:trap_exit, true)

      catch_exit(
        view
        |> form("#message-form", message: %{content: nil})
        |> render_submit()
      )

      assert_receive {:EXIT, _, {{:badmatch, _}, _}}
    end

    test "User presence detected", %{conn: conn, user: user} do
      {:ok, view, _html} = live(conn, @chat_path)

      assert render_element(view, "#users-container") =~ "@#{user.username}"

      %{conn: conn2, user: user2} = new_user()

      refute render_element(view, "#users-container") =~ "@#{user2.username}"

      conn2 = log_in_user(conn2, user2)
      {:ok, view2, _html} = live(conn2, @chat_path)

      users_div = render_element(view, "#users-container")

      assert users_div =~ "@#{user.username}"
      assert users_div =~ "@#{user2.username}"

      users_div2 = render_element(view2, "#users-container")

      assert users_div2 =~ "@#{user.username}"
      assert users_div2 =~ "@#{user2.username}"
    end

    test "Message from another user appears in chat", %{conn: conn} do
      {:ok, view, _html} = live(conn, @chat_path)

      %{conn: conn2, user: user2} = new_user()
      conn2 = log_in_user(conn2, user2)
      {:ok, view2, _html} = live(conn2, @chat_path)

      refute render_element(view, "#chat-container") =~ "#{@valid_message_attrs.content}"
      refute render_element(view2, "#chat-container") =~ "#{@valid_message_attrs.content}"

      view
      |> form("#message-form", message: @valid_message_attrs)
      |> render_submit()

      assert render_element(view, "#chat-container") =~ "#{@valid_message_attrs.content}"
      assert render_element(view2, "#chat-container") =~ "#{@valid_message_attrs.content}"
    end

    defp new_user() do
      conn = Phoenix.ConnTest.build_conn()
      user = confirmed_user_fixture(%{email: unique_user_email(), username: unique_username()})
      %{conn: conn, user: user}
    end

    defp render_element(view, selector) do
      view
      |> element(selector)
      |> render()
    end
  end
end
