 <?php
$servername = getenv('DB_HOST');
$username = getenv('DB_USER');
$password = getenv('DB_PASSWORD');
$dbname = getenv('DB_NAME');

try {
    $conn = new PDO("pgsql:host=$servername;dbname=$dbname", $username, $password);
    // set the PDO error mode to exception
    $conn->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
    $sql = "CREATE TABLE IF NOT EXISTS test(id int)";
    $conn->exec($sql);
    $sql = "INSERT INTO test VALUES (".$_GET["id"].")";
    // use exec() because no results are returned
    $conn->exec($sql);
    echo "id from get=".$_GET["id"]." from post=".$_POST["id"]." New record created successfully";
    }
catch(PDOException $e)
    {
    echo $sql . "<br>" . $e->getMessage();
    }

$conn = null;
?>
