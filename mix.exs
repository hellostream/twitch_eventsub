defmodule TwitchEventSub.MixProject do
  use Mix.Project

  @version "0.2.1"
  @repo_url "https://github.com/hellostream/twitch_eventsub"

  def project do
    [
      app: :hello_twitch_eventsub,
      version: @version,
      elixir: "~> 1.16",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      description: description(),
      package: package(),
      source_url: @repo_url,
      homepage_url: @repo_url
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:hello_twitch_api, "~> 0.5.1"},
      {:jason, "~> 1.4"},
      {:req, "~> 0.4"},
      {:plug, "~> 1.15", optional: true},
      {:websockex, "~> 0.4.3", optional: true},
      {:ex_doc, "~> 0.31.2", only: [:dev], runtime: false}
    ]
  end

  defp description do
    """
    Twitch EventSub for Elixir
    """
  end

  defp package do
    [
      licenses: ["Apache-2.0"],
      links: %{"GitHub" => @repo_url}
    ]
  end
end
