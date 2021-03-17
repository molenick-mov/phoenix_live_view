defmodule Phoenix.LiveView.ComponentForwardPhxValueBugTest do
  use ExUnit.Case, async: false

  import Phoenix.LiveViewTest

  alias Phoenix.LiveViewTest.Endpoint

  @endpoint Endpoint

  setup config do
    {:ok,
     conn: Plug.Test.init_test_session(Phoenix.ConnTest.build_conn(), config[:session] || %{})}
  end

  defmodule MyComponent do
    use Phoenix.LiveComponent
    import Phoenix.HTML.Link

    @impl true
    def mount(socket) do
      {:ok, assign(socket, :message, "blank")}
    end

    @impl true
    def render(assigns) do
      ~L"""
        <%= link("Perform", to: "#", phx_value_message: "live view is cool", phx_click: :perform_click, phx_target: @myself) %>
      """
    end
  end

  defmodule MyLiveView do
    use Phoenix.LiveView

    import Phoenix.HTML.Link

    @impl true
    def mount(_params, _session, socket) do
      {:ok, assign(socket, :message, "blank")}
    end

    @impl true
    def render(assigns) do
      ~L"""
      <div>
        <p>The message is <%= @message %>
        <%= live_component @socket, MyComponent, id: "my-component-1" %>
      </div>
      """
    end

    @impl true
    def handle_event(_event, %{"message" => message}, socket) do
      IO.inspect(message)
      {:noreply, assign(socket, :message, message)}
    end
  end

  test "forwards phx-value params when clicking using the link text", %{conn: conn} do
    {:ok, view, html} = live_isolated(conn, MyLiveView)

    assert html =~ "The message is blank"

    html = view |> render_click("Perform")

    assert html =~ "The message is live view is cool"
  end
end
