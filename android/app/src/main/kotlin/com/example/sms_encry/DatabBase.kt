import android.content.Context
import android.database.sqlite.SQLiteDatabase
import android.database.sqlite.SQLiteOpenHelper

class DatabaseHelper(context: Context) : SQLiteOpenHelper(context, DATABASE_NAME, null, DATABASE_VERSION) {

    companion object {
        private const val DATABASE_NAME = "sms_database.db"
        private const val DATABASE_VERSION = 1
        private const val TABLE_NAME = "sms_table"
        private const val COLUMN_ID = "_id"
        private const val COLUMN_SENDER = "sender"
        private const val COLUMN_MESSAGE_BODY = "message_body"
    }

    override fun onCreate(db: SQLiteDatabase?) {
        // Create the database table(s) here
        db?.execSQL(
            "CREATE TABLE $TABLE_NAME ($COLUMN_ID INTEGER PRIMARY KEY AUTOINCREMENT, " +
                    "$COLUMN_SENDER TEXT, $COLUMN_MESSAGE_BODY TEXT)"
        )
    }

    override fun onUpgrade(db: SQLiteDatabase?, oldVersion: Int, newVersion: Int) {
        // Handle database schema upgrades here, if any
        // This method is called when the DATABASE_VERSION is increased
        // You can implement database schema migration logic here
    }
}