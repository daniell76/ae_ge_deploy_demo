import os

from dotenv import load_dotenv

from google.adk.agents import Agent
from google.adk.tools.bigquery import BigQueryToolset
from google.adk.tools.bigquery.config import BigQueryToolConfig
from google.adk.tools.bigquery.config import WriteMode

load_dotenv()

# Define constants for this example agent
AGENT_NAME = "bigquery_agent"
GEMINI_MODEL = os.getenv("ROOT_AGENT_MODEL")

# Define a tool configuration to block any write operations
tool_config = BigQueryToolConfig(write_mode=WriteMode.BLOCKED)

# Instantiate a BigQuery toolset
bigquery_toolset = BigQueryToolset(bigquery_tool_config=tool_config)

BQ_PROJECT = os.environ['GOOGLE_CLOUD_PROJECT']
DATASET_NAME = "uk_pub_data"  # replace with your dataset name

# Agent Definition
bigquery_agent = Agent(
    model=GEMINI_MODEL,
    name=AGENT_NAME,
    description=(
        "Agent to answer questions about BigQuery data and models and execute"
        " SQL queries."
    ),
    instruction=(
        "You are a data science agent with access to several BigQuery tools.\n"
        "Make use of those tools to answer the user's questions.\n"
        f"You must always use dataset {DATASET_NAME} in project {BQ_PROJECT} for your queries.\n"
    ),
    tools=[bigquery_toolset],
)
