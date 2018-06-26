using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class MicInput : MonoBehaviour {

	// Use this for initialization
	void Start () {
		AudioSource aud = GetComponent<AudioSource>();
        aud.clip = Microphone.Start(Microphone.devices[0], true, 10, 44100);
        aud.Play();
	}
	
	// Update is called once per frame
	void Update () {
		
	}
}
