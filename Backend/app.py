from flask import Flask, request, jsonify

app = Flask(__name__)

@app.route('/posts', methods=['POST'])
def handle_post():
    # Get JSON data from the incoming POST request
    data = request.get_json()
    project = data.get('project')
    date = data.get('date')
    test = data.get('test')

    # Print the received data for debugging
    print(f"Received post with project: {project}, date: {date}, test: {test}")

    # Simulate processing and return the response
    return jsonify({
        'project': project,
        'date': date,
        'test': test,
    }), 200

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)
