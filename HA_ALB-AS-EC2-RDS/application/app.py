from flask import Flask, jsonify, send_from_directory
import pymysql
import os
from datetime import datetime
import logging

# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

app = Flask(__name__, static_folder='frontend', static_url_path='')

# Database configuration from environment variables
DB_CONFIG = {
    'host': os.environ.get('DB_HOST', 'localhost'),
    'user': os.environ.get('DB_USER', 'admin'),
    'password': os.environ.get('DB_PASSWORD', 'password'),
    'database': os.environ.get('DB_NAME', 'aws_demo'),
    'port': int(os.environ.get('DB_PORT', 3306)),
    'connect_timeout': 5
}

DB_NAME = os.environ.get('DB_NAME', 'aws_demo')

def get_db_connection():
    """Establish database connection"""
    try:
        # First connect without database to create it if needed
        connection = pymysql.connect(
            host=DB_CONFIG['host'],
            user=DB_CONFIG['user'],
            password=DB_CONFIG['password'],
            port=DB_CONFIG['port'],
            connect_timeout=DB_CONFIG['connect_timeout'],
            cursorclass=pymysql.cursors.DictCursor
        )
        
        # Create database if it doesn't exist
        with connection.cursor() as cursor:
            cursor.execute(f"CREATE DATABASE IF NOT EXISTS `{DB_NAME}`")
            cursor.execute(f"USE `{DB_NAME}`")
        
        return connection
    except Exception as e:
        logger.error(f"Database connection error: {str(e)}")
        raise

def init_database():
    """Initialize database with demo table if it doesn't exist"""
    try:
        connection = get_db_connection()
        with connection.cursor() as cursor:
            # Create demo table
            cursor.execute("""
                CREATE TABLE IF NOT EXISTS app_metrics (
                    id INT AUTO_INCREMENT PRIMARY KEY,
                    metric_name VARCHAR(100),
                    metric_value VARCHAR(255),
                    timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP
                )
            """)
            
            # Insert initial metric if table is empty
            cursor.execute("SELECT COUNT(*) as count FROM app_metrics")
            result = cursor.fetchone()
            
            if result['count'] == 0:
                cursor.execute("""
                    INSERT INTO app_metrics (metric_name, metric_value)
                    VALUES ('app_start', 'Application initialized')
                """)
            
            connection.commit()
            logger.info("Database initialized successfully")
    except Exception as e:
        logger.error(f"Database initialization error: {str(e)}")
    finally:
        if connection:
            connection.close()

@app.route('/')
def index():
    """Serve the main HTML page"""
    return send_from_directory('frontend', 'index.html')

@app.route('/api/db-status')
def db_status():
    """Get database status and information"""
    try:
        connection = get_db_connection()
        
        with connection.cursor() as cursor:
            # Get basic database info
            db_info = {
                'status': 'available',
                'engine': 'MySQL',
                'host': DB_CONFIG['host'],
                'database': DB_NAME
            }
            
            # Get MySQL version
            cursor.execute("SELECT VERSION() as version")
            version_result = cursor.fetchone()
            db_info['engine_version'] = version_result['version'].split('-')[0] if version_result else 'Unknown'
            
            # Get active connections
            cursor.execute("SHOW STATUS LIKE 'Threads_connected'")
            connections_result = cursor.fetchone()
            db_info['connections'] = int(connections_result['Value']) if connections_result else 0
            
            # Get uptime
            cursor.execute("SHOW STATUS LIKE 'Uptime'")
            uptime_result = cursor.fetchone()
            if uptime_result:
                uptime_seconds = int(uptime_result['Value'])
                db_info['uptime_hours'] = uptime_seconds / 3600
            else:
                db_info['uptime_hours'] = 0
            
            # Simulate Multi-AZ and other AWS-specific info
            # In a real scenario, you would get this from AWS API or RDS metadata
            db_info['multi_az'] = os.environ.get('MULTI_AZ', 'true').lower() == 'true'
            db_info['storage_gb'] = int(os.environ.get('STORAGE_GB', 100))
            db_info['instance_class'] = os.environ.get('INSTANCE_CLASS', 'db.t3.medium')
            db_info['availability_zone'] = os.environ.get('AZ', 'us-east-1a')
            
            # Get record count from demo table
            try:
                cursor.execute("SELECT COUNT(*) as count FROM app_metrics")
                count_result = cursor.fetchone()
                db_info['demo_records'] = count_result['count'] if count_result else 0
            except:
                db_info['demo_records'] = 0
            
            connection.close()
            
            logger.info("Database status retrieved successfully")
            return jsonify(db_info)
            
    except Exception as e:
        logger.error(f"Error getting database status: {str(e)}")
        return jsonify({
            'status': 'error',
            'message': str(e),
            'engine': 'MySQL',
            'engine_version': 'Unknown',
            'multi_az': False,
            'storage_gb': 0,
            'instance_class': 'Unknown',
            'availability_zone': 'Unknown',
            'connections': 0,
            'uptime_hours': 0
        }), 500

@app.route('/api/health')
def health_check():
    """Health check endpoint"""
    try:
        connection = get_db_connection()
        connection.close()
        return jsonify({
            'status': 'healthy',
            'database': 'connected',
            'timestamp': datetime.now().isoformat()
        })
    except Exception as e:
        return jsonify({
            'status': 'unhealthy',
            'database': 'disconnected',
            'error': str(e),
            'timestamp': datetime.now().isoformat()
        }), 503

@app.route('/api/test-query')
def test_query():
    """Execute a simple test query"""
    try:
        connection = get_db_connection()
        with connection.cursor() as cursor:
            # Insert a test metric
            cursor.execute("""
                INSERT INTO app_metrics (metric_name, metric_value)
                VALUES ('api_call', 'Test query executed')
            """)
            connection.commit()
            
            # Get recent metrics
            cursor.execute("""
                SELECT * FROM app_metrics 
                ORDER BY timestamp DESC 
                LIMIT 5
            """)
            results = cursor.fetchall()
            
            connection.close()
            
            return jsonify({
                'status': 'success',
                'message': 'Query executed successfully',
                'recent_metrics': results
            })
    except Exception as e:
        logger.error(f"Test query error: {str(e)}")
        return jsonify({
            'status': 'error',
            'message': str(e)
        }), 500

if __name__ == '__main__':
    # Initialize database on startup
    try:
        init_database()
    except Exception as e:
        logger.warning(f"Could not initialize database on startup: {str(e)}")
        logger.warning("Application will continue, but database features may not work")
    
    # Run the Flask app
    port = int(os.environ.get('PORT', 5000))
    app.run(host='0.0.0.0', port=port, debug=False)