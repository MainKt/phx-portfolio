defmodule PortfolioWeb.HomeLive do
  use PortfolioWeb, :live_view

  def mount(_params, _session, socket) do
    socket =
      socket
      |> assign(:page_title, "~")
      |> assign(:page_heading, "Muhammad Saheed =^.^=")

    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <section id="about">
      <h2>About Me</h2>
      <p>
        Hi There, ヾ(˶ᵔ ᗜ ᵔ˶) I'm Muhammad Saheed!
        I go by a lot of different names online:
        MainKt on GitHub, main.ll on Discord, unwrapped_monad on IRC and X.
        No idea how it ended up this way ¯\_(ツ)_/¯
      </p>
      <p>
        I like open source software, enjoy tinkering with code,
        and learning and playing with CLI tools.
        I love linux and *BSDs,
        I daily drive arch linux and also use FreeBSD btw.
        <span style="white-space: nowrap;">(,,&gt;﹏&lt;,,)</span>
      </p>
      <p>
        I love ricing and optimizing my workflow in my free time
        with window managers and vim,
        but maybe it's a vice (ᵕ—ᴗ—).
      </p>
      <p>
        I also love low-level systems programming and enjoy building and
        rewriting tools that I find fun in Zig and Rust.
        I'm also a fan of Erlang and it's concurrency model. d(^U^)z
      </p>
    </section>

    <section id="contact">
      <h2>Contact</h2>
      <p>You can reach me through the following:</p>
      <dl>
        <dt>Email</dt>
        <dd>
          <a href="mailto:muhammad.saheed.iam AT gmail DOT com">
            muhammad.saheed.iam AT gmail DOT com
          </a>
        </dd>

        <dt>IRC</dt>
        <dd>unwrapped_monad AT libera.chat</dd>

        <dt>GitHub</dt>
        <dd>
          <a href="https://github.com/MainKt" target="_blank" rel="noopener noreferrer">MainKt</a>
        </dd>

        <dt>X</dt>
        <dd>
          <a href="https://x.com/unwrapped_monad" target="_blank" rel="noopener noreferrer">
            unwrapped_monad
          </a>
        </dd>

        <dt>Discord</dt>
        <dd>main.ll</dd>
      </dl>
    </section>
    """
  end
end
