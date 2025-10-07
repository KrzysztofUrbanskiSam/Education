# Hackaton Project

This project consists of a React frontend and an Express backend working together to generate responses for creative content.

## Project Structure

```
hackaton/
├── backend/
│   ├── server.js          # Express server
│   ├── my-script.sh       # Shell script for processing
│   ├── package.json       # Backend dependencies
│   └── mocks/             # Mock data files
└── frontend/
    ├── src/               # React source code
    ├── package.json       # Frontend dependencies
    └── public/            # Static assets
```

## Prerequisites

- Node.js (version 14 or higher)
- npm (comes with Node.js)
- Git

## Getting Started

### Backend Setup

1. Navigate to the backend directory:
   ```bash
   cd backend
   ```

2. Install dependencies:
   ```bash
   npm install
   ```

3. Start the backend server:
   ```bash
   node server.js
   ```

   The backend server will start on port 5000 by default.
   You can access it at: http://localhost:5000

### Frontend Setup

1. Navigate to the frontend directory:
   ```bash
   cd frontend
   ```

2. Install dependencies:
   ```bash
   npm install
   ```

3. Start the frontend development server:
   ```bash
   npm start
   ```

   The frontend will start on port 3001 (configured in package.json).
   You can access it at: http://localhost:3001

## Usage

1. Make sure both backend and frontend servers are running
2. Open your browser and go to http://localhost:3001
3. Use the interface to:
   - Enter creative IDs
   - Select TV models
   - Enter branch name
   - Choose creative type
   - Run the script or open mock patterns

## Development

### Backend Development

The backend is built with Express.js and provides the following endpoints:

- `GET /` - Welcome message
- `POST /script` - Execute the shell script with provided parameters
- `POST /upload` - Load mock data based on creative type
- `GET /api/status` - Check server status

To modify the backend:
1. Edit `backend/server.js`
2. Restart the server to see changes

### Frontend Development

The frontend is built with React and consists of:

- `App.js` - Main application component
- `App.css` - Styling with Samsung design language

To modify the frontend:
1. Edit files in `frontend/src/`
2. Changes will automatically reload in the browser

### Available Scripts

In the frontend directory, you can run:

- `npm start` - Runs the app in development mode
- `npm test` - Launches the test runner
- `npm run build` - Builds the app for production
- `npm run eject` - Removes the single build dependency

## Troubleshooting

### Common Issues

1. **Port already in use**
   - If port 5000 or 3001 is already in use, you can change the ports:
     - Backend: Modify the PORT variable in `backend/server.js`
     - Frontend: Change the PORT in `frontend/package.json` start script

2. **CORS errors**
   - The backend already has CORS enabled, but if you encounter issues:
     - Check that both servers are running
     - Verify the frontend is making requests to the correct backend URL

3. **Dependency installation errors**
   - Delete `node_modules` folders and `package-lock.json` files in both directories
   - Run `npm install` again in each directory

### Server Status

You can check if the backend server is running by visiting:
http://localhost:5000/api/status

## Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a pull request

## License

This project is licensed under the MIT License.

## Contact

For questions or support, please open an issue in the repository.
