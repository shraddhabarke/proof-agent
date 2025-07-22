import subprocess

def run_graphrag_query(query):
    #query = "What is F*?"
    command = f'graphrag query --root ./rag --method local --query "{query}"'

    try:
        result = subprocess.run(
            command,
            shell=True,
            text=True,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            check=True
        )
        output = result.stdout
        print("SUCCESS: Global Search Response:\n")
        print(result.stdout)
        return output
    except subprocess.CalledProcessError as e:
        print("ERROR executing graphrag query:")
        print(e.stderr)
        return None