# Ad Response Generator

This project consists of a React frontend and an Express backend working together.
It allows users to generate and validate ad responses for different creative IDs.

## Project Structure

```
ad_response_generator/
├── backend/
│   ├── server.js          # Express server
│   ├── validators.js      # Validation functions
│   ├── package.json       # Backend dependencies
│   └── mocks/             # Mock data files
├── frontend/
│   ├── src/
│   │   ├── App.js         # Main application component
│   │   ├── App.css        # Styling
│   │   ├── InputComponents/  # Input components (CreativeIdsInput, BranchNameInput, etc.)
│   │   ├── outputComponents/ # Output components (OutputSection, PatternSection, etc.)
│   │   └── Loader.js      # Loading component
│   ├── package.json       # Frontend dependencies
│   └── public/            # Static assets
├── runs/                  # Generated ad reposnses json(s) and other staff
├── utils/                 # Utility scripts
└── extract_parquet_files.py  # Parquet file extraction script
```

## Prerequisites

- Node.js (version 14 or higher)
- npm (comes with Node.js)
- Git
- Python 3 (for parquet file processing)
- Erlang (for term data generation)

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

   The frontend will start on port 3011
   You can access it at: http://localhost:3011

## Usage

1. Make sure both backend and frontend servers are running
2. Open your browser and go to http://localhost:3011
3. Use the interface to:
   - Enter creative IDs (comma-separated)
   - Enter branch names for data-activation and rtb-bidder
   - Select language
   - Run the ad response generation script
   - View and validate generated ad responses
   - Show/hide response content
   - Copy responses to clipboard

## Features

- **Ad Response Generation**: Generate ad responses for specified creative IDs
- **Response Validation**: Validate generated ad responses
- **Multiple Creative Support**: Process multiple creative IDs at once
- **Response Visualization**: View ad responses in a formatted display
- **Copy to Clipboard**: Easily copy responses for further use
- **Test Mode**: Toggle test mode to view pattern templates

## Development

### Backend Development

The backend is built with Express.js and provides the following endpoints:

- `GET /` - Welcome message
- `POST /script` - Execute the shell script with provided parameters
- `POST /upload_mock` - Load mock data based on creative type
- `GET /api/status` - Check server status
- `POST /open_ad_response` - Open and retrieve ad response file content
- `POST /validate` - Validate generated ad response

To modify the backend:

1. Edit `backend/server.js`
2. Restart the server to see changes

### Frontend Development

The frontend is built with React and consists of:

- `App.js` - Main application component
- `App.css` - Styling with custom design
- Input Components:
  - `CreativeIdsInput` - For entering creative IDs
  - `BranchNameInput` - For entering branch names
  - `LanguageSelect` - For selecting language
  - `CreativeTypeSelect` - For selecting creative type (in test mode)
- Output Components:
  - `OutputSection` - Displays generated ad responses
  - `PatternSection` - Displays pattern templates (in test mode)
  - `Loader` - Loading indicator

To modify the frontend:

1. Edit files in `frontend/src/`
2. Changes will automatically reload in the browser

### Available Scripts

In the project directory, you can run:

- `npm start` - Runs the app in development mode
- `npm test` - Launches the test runner
- `npm run build` - Builds the app for production
- `npm run eject` - Removes the single build dependency

## Troubleshooting

### Common Issues

1. **Port already in use**

   - If port 5000 or 3011 is already in use, you can change the ports:
     - Backend: Modify the PORT variable in `backend/server.js`
     - Frontend: Set PORT environment variable before running

2. **CORS errors**

   - The backend already has CORS enabled, but if you encounter issues:
     - Check that both servers are running
     - Verify the frontend is making requests to the correct backend URL

3. **Dependency installation errors**

   - Delete `node_modules` folders and `package-lock.json` files in both directories
   - Run `npm install` again in each directory

4. **Python or Erlang not configured**
   - The application may show warnings if Python3 or Erlang is not installed
   - These are required for certain data processing features

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
