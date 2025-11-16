from my_agent.utils.config import ROOT_AGENT_MODEL
from google.adk.agents import Agent
import textwrap

PROMPT = textwrap.dedent(
    """
    You are an expert travel destination analyst.
    Your goal is to recommend the top 3 travel destinations based on the user's request.
    You must use the search tool to find the best destinations.
    For each destination, you must provide:
    - The name of the destination.
    - A brief description of why it's a good fit.
    - The estimated cost for flights and accommodation.
    """
)

destination_analyst_agent = Agent(
    name="DestinationAnalystAgent",
    model=ROOT_AGENT_MODEL,
    description="Analyzes and recommends top travel destinations based on user preferences.",
    instruction=PROMPT,
    output_key="destination_analyst_output",
)
