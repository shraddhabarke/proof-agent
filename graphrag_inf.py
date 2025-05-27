import subprocess

def run_graphrag_query(query):
    #query = "What is F*?"
    command = f'graphrag query --root ~/graphrag/ragtest/ --method global --query "{query}"'

    try:
        result = subprocess.run(
            command,
            shell=True,
            text=True,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            check=True
        )
        print("SUCCESS: Global Search Response:\n")
        print(result.stdout)
    except subprocess.CalledProcessError as e:
        print("ERROR executing graphrag query:")
        print(e.stderr)

if __name__ == "__main__":
    run_graphrag_query("What is F*?")
