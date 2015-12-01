using UnityEngine;
using System.Collections;

public class GalleryTrigger : MonoBehaviour {
	MeshRenderer renderer;
	Material mat;	
	float timer;
	Light[] lights;

//	float lightLast = 0;
//	float lightTarg = 0;
//	float lightPCT = 0;
	float lightIntensity = 4f;	//1.5
	float lightAngle = 100;

	bool active;
	// Use this for initialization
	void Start () {
		renderer = GetComponentInChildren<MeshRenderer> ();
		if (renderer != null) {
			mat = renderer.material;
		}

		lights = GetComponentsInChildren<Light> ();
		for (int i = 0; i < lights.Length; i++) {
			lights[i].intensity = 0;
			lights[i].spotAngle = 0;
		}
	}
	
	// Update is called once per frame
	void Update () {
		bool disable = true; 

		timer += (active) ? Time.deltaTime : -(Time.deltaTime * 3);

		float targVal = (timer > 0) ? lightIntensity : 0;
		float targAngle = (timer > 0) ? lightAngle : 0;
		for (int i = 0; i < lights.Length; i++) {
			lights[i].intensity = Mathf.Lerp (lights[i].intensity, targVal, 0.2f);
			lights[i].spotAngle = Mathf.Lerp (lights[i].spotAngle, targAngle, 0.2f);
			if (lights[i].intensity > 0.05f) disable = false;
		}
		mat.SetFloat ("_Timer", Mathf.Max (0, timer));

		if (disable) enabled = false;
	}

	void OnTriggerEnter (Collider hit) {
		if (hit.CompareTag ("Player") && mat != null) {
			if (!enabled) enabled = true;
			active = true;
			timer = 0;
		}
	}
	void OnTriggerExit (Collider hit) {
		if (hit.CompareTag ("Player")) {
			mat.SetFloat ("_Timer", 0);
			active = false;
		}
	}
}
