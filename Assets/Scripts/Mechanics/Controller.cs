using UnityEngine;
using System.Collections;

//Mouse look adapted from community solution, found here: http://answers.unity3d.com/questions/29741/mouse-look-script.html
[RequireComponent(typeof(Rigidbody))]
public class Controller : MonoBehaviour {
	Rigidbody rigid;
	Transform tr;
	public Transform headTr;

	public enum RotationAxes { MouseXAndY = 0, MouseX = 1, MouseY = 2 }
	public RotationAxes axes = RotationAxes.MouseXAndY;
	public float sensitivityX = 15F;
	public float sensitivityY = 15F;
	
	float minimumX = -360F;
	float maximumX = 360F;
	
	float minimumY = -60F;
	float maximumY = 60F;

	float rotationY = 0F;


	float maxSpeed = 3000;
	void Awake () {
//		rigid = GetComponentsInParent<Rigidbody> ()[1];
		rigid = GetComponent<Rigidbody> ();
		tr = transform;
		Screen.fullScreen = true;
		Cursor.visible = false;
	}


	public float hitDist = 5f;
	public LayerMask groundLayer;
	public bool isGrounded {
		get {
			if (Physics.Raycast (tr.position, Vector3.down, hitDist, groundLayer)) return true;
			else return false;
		}
	}

	bool swinging;
	public HookShot hookShot;

	public float speed = 5;
	public float runSpeed = 25;
	public float rotateSpeed = 15;
	public float jumpHeight = 50;

	float curSpeed {
		get {
			float returnVal = 0;
			if (Input.GetKey(KeyCode.LeftShift)) 
				returnVal = runSpeed;
			else 
				returnVal = speed;

			if (rigid != null && !rigid.useGravity) {
				returnVal *= 4.0f;
			}
			return returnVal;
		}
	}
//	bool grounded;
	[SerializeField] bool lookEnabled;
	[SerializeField] bool moveEnabled;
	public void SetActions (bool _look, bool _move) {
		lookEnabled = _look;
		moveEnabled = _move;
	}
	void Update () {
		if (Input.GetKeyDown (KeyCode.F)) {
			Screen.fullScreen = !Screen.fullScreen;
		}
		if (lookEnabled) {
			if (axes == RotationAxes.MouseXAndY)
			{
				float rotationX = headTr.localEulerAngles.y + Input.GetAxis("Mouse X") * sensitivityX;
				
				rotationY += Input.GetAxis("Mouse Y") * sensitivityY;
				rotationY = Mathf.Clamp (rotationY, minimumY, maximumY);
				
				headTr.localEulerAngles = new Vector3(-rotationY, rotationX, 0);
			}
			else if (axes == RotationAxes.MouseX)
			{
				headTr.Rotate(0, Input.GetAxis("Mouse X") * sensitivityX, 0);
			}
			else
			{
				rotationY += Input.GetAxis("Mouse Y") * sensitivityY;
				rotationY = Mathf.Clamp (rotationY, minimumY, maximumY);
				
				headTr.localEulerAngles = new Vector3(-rotationY, transform.localEulerAngles.y, 0);
			}
		}
		if (moveEnabled) {
			xSpeed = curSpeed * Input.GetAxis ("Horizontal");
			zSpeed = curSpeed * Input.GetAxis ("Vertical");
			ySpeed = Physics.gravity.y;
			
			if (!jumping && Input.GetButtonDown ("Jump")) {
				if (Mathf.Abs (rigid.velocity.y) < 2) {
					jumping = true;
				}
				
			}
			
			if (Input.GetKeyDown (KeyCode.Tab)) {
				if (rigid != null) {
					rigid.useGravity = !rigid.useGravity;
				}
			}
		}
	}
	float xSpeed, ySpeed, zSpeed;
	bool jumping;


	void FixedUpdate () {
		if (jumping) {
			jumping = false;
			if (Mathf.Abs (rigid.velocity.y) < 2) {
				rigid.AddForce (Vector3.up * jumpHeight, ForceMode.Impulse);
			}
		}
		float newY = 0;

		if (moveEnabled) {
			Vector3 newMove = headTr.TransformDirection (new Vector3 (xSpeed, 0, zSpeed));
			if (rigid.useGravity) newMove.y = rigid.velocity.y;
			rigid.velocity = newMove;
		}

	}
}
