defmodule Phoenix.LiveView.ComponentHandleEventBugTest do
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
      <p>The message is <%= @message %>
      <%= link("Perform", to: "#", phx_click: "Perform", phx_target: @myself) %>
      """
    end

    @impl true
    def handle_event(_event, _params, socket) do
      {:noreply, assign(socket, :message, "live view is cool")}
    end
  end

  defmodule MyLiveView do
    use Phoenix.LiveView

    @impl true
    def render(assigns) do
      ~L"""
      <div>
      <%= live_component @socket, MyComponent, id: "my-component-1" %>
      </div>
      """
    end
  end

  test "delegates event to component", %{conn: conn} do
    {:ok, view, html} = live_isolated(conn, MyLiveView)

    assert html =~ "The message is blank"

    html = view |> render_click("Perform")

    assert html =~ "The message is live view is cool"
  end
end
