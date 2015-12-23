using UnityEngine;
using System.Collections;

//Mouse look adapted from community solution, found here: http://answers.unity3d.com/questions/29741/mouse-look-script.html
[RequireComponent(typeof(Rigidbody))]
public class Controller2: MonoBehaviour {
	
	[SerializeField] Renderer screenBlock;
	[SerializeField] bool lookEnabled;
	[SerializeField] bool moveEnabled;
	[SerializeField] Transform headTr;	//child transform attached to main body with camera (or camera as child)
		
	//control movement speed
	public float speed = 5;
	public float runSpeed = 25;
	public float jumpHeight = 50;
	
	//control look speed
	public float sensitivityX = 15F;
	public float sensitivityY = 15F;
	
	//control ground check
	public LayerMask groundLayer;
	float hitDist = 5f;
	public bool isGrounded {
		get {
			if (Physics.Raycast (tr.position, Vector3.down, hitDist, groundLayer)) return true;
			else return false;
		}
	}
	
	//control look y range
	float minimumY = -60F;
	float maximumY = 60F;
	float rotationY = 0;

	//cached components for better performance
	Rigidbody rigid;
	Transform tr;

	void Awake () {
		rigid = GetComponent<Rigidbody> ();
		tr = transform;
		
		//setting the camera obscuring fade-in material for the start of the scene
		Color col = screenBlock.material.color;
		col.a = 1;
		screenBlock.material.color = col;
	}


	float maxSpeed {
		get {
			float returnVal = (Input.GetKey(KeyCode.LeftShift)) ? runSpeed : speed;	//check if running
			if (rigid != null && !rigid.useGravity) returnVal *= 4.0f;				//free-fly speed adjust				
			return returnVal;
		}
	}
	

	public void SetActions (bool _look, bool _move) {
		lookEnabled = _look;
		moveEnabled = _move;
	}
	
	bool canMove = false;
	float initTimer;
	void Update () {
		if (!canMove) {	//for scene start, fade-in intro
			initTimer += Time.deltaTime;
			Color col = screenBlock.material.color;
			col.a -= 0.3f * Time.deltaTime;
			screenBlock.material.color = col;
			if (initTimer > 3) {
				col.a = 0;
				screenBlock.material.color = col;
				canMove = true;
			}
			else return;
		}
		if (lookEnabled) {	//set look rotation
			float rotationX = headTr.localEulerAngles.y + (Input.GetAxis("Mouse X") * sensitivityX);
			rotationY += Input.GetAxis("Mouse Y") * sensitivityY;
			rotationY = Mathf.Clamp (rotationY, minimumY, maximumY);	//limit the up or down rotation
			headTr.localEulerAngles = new Vector3(-rotationY, rotationX, 0);
		}
		if (moveEnabled) {	//set movement speed (actually processed in FixedUpdate)
			curSpeed.Set (maxSpeed * Input.GetAxis ("Horizontal"), Physics.gravity.y, maxSpeed * Input.GetAxis ("Vertical"));
			
			if (Input.GetKeyDown (KeyCode.Tab)) {	//enable free-fly
				if (rigid != null) {
					rigid.useGravity = !rigid.useGravity;
				}
			}
		}
	}

	// float xSpeed, ySpeed, zSpeed;
	Vector3 curSpeed;
	bool jumping;
	//do actual movement here to make use of physics
	void FixedUpdate () {
		if (jumping) {
			jumping = false;
			if (Mathf.Abs (rigid.velocity.y) < 2) {
				rigid.AddForce (Vector3.up * jumpHeight, ForceMode.Impulse);
			}
		}
		if (moveEnabled) {
			Vector3 newMove = headTr.TransformDirection (curSpeed.x, 0, curSpeed.z);
			if (rigid.useGravity) newMove.y = rigid.velocity.y;
			rigid.velocity = newMove;
		}

	}
}
