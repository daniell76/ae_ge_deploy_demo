from my_agent.utils.config import ROOT_AGENT_MODEL
from google.adk.agents import Agent
import textwrap

PROMPT = textwrap.dedent(
    """
    You are an expert travel logistics coordinator.
    Your goal is to find the best flight and accommodation options for the top 3 recommended destinations.
    You must use the search tool to find the information.
    For each destination, you must provide:
    - 1 flight option (airline, price, and duration).
    - 2 accommodation options (e.g., a hotel and a vacation rental), with prices.
    """
)

logistics_coordinator_agent = Agent(
    name="LogisticsCoordinatorAgent",
    model=ROOT_AGENT_MODEL,
    description="Coordinates travel logistics including flights and accommodations for recommended destinations.",
    instruction=PROMPT,
    output_key="logistics_coordinator_output"
)
