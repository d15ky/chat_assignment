defmodule ChatAssignment.AccountsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `ChatAssignment.Accounts` context.
  """
  alias ChatAssignment.Accounts

  def unique_user_email, do: "user#{System.unique_integer()}@example.com"

  def unique_username, do: String.slice("user#{System.unique_integer([:positive])}", 0..30)
  def valid_user_password, do: "hello world!"

  def valid_user_attributes(attrs \\ %{}) do
    Enum.into(attrs, %{
      email: unique_user_email(),
      password: valid_user_password(),
      username: unique_username()
    })
  end

  def user_fixture(attrs \\ %{}) do
    {:ok, user} =
      attrs
      |> valid_user_attributes()
      |> Accounts.register_user()

    user
  end

  def confirmed_user_fixture(attrs \\ %{}) do
    user = user_fixture(attrs)

    token =
      extract_user_token(fn url ->
        Accounts.deliver_user_confirmation_instructions(user, url)
      end)

    {:ok, confirmed_user} = Accounts.confirm_user(token)

    confirmed_user
  end

  def extract_user_token(fun) do
    {:ok, captured_email} = fun.(&"[TOKEN]#{&1}[TOKEN]")
    [_, token | _] = String.split(captured_email.text_body, "[TOKEN]")
    token
  end
end
