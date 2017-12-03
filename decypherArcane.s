.data
java_method_name:
	.asciz "revealTheSecret"
java_method_signature:
	.asciz "(Ljava/lang/String;)V"

// Our UTF16-LE encoded secret message
secret:
	.hword 55357, 56892, 85, 110, 32, 99, 104, 97, 116, 10
	.hword 55357, 56377, 12495, 12512, 12473, 12479, 12540, 10
	.hword 55357, 56360, 27193, 29066, 10
	.hword 55357, 56445, 65, 110, 32, 97, 108, 105, 101, 110, 10
secret_len = (. - secret) / 2

.text
.align 2
.globl Java_adventurers_decyphering_secrets_decyphapp_DecypherActivity_decypherArcaneSecrets
.type Java_adventurers_decyphering_secrets_decyphapp_DecypherActivity_decypherArcaneSecrets, %function
Java_adventurers_decyphering_secrets_decyphapp_DecypherActivity_decypherArcaneSecrets:
	sub sp, sp, 48 // Prepare to push x19, x20, x21, x22 and lr (x30)
	               // 5 registers of 8 bytes each -> 40 bytes
	               // Unless you like to deal with corner cases, you'll
	               // have to keep the stack aligned on 16 bytes.
	               // 40 % 16 != 0 but 48 % 16 == 0, so we use 48 bytes.
	stp x19, x20, [sp]
	stp x21, x22, [sp, 16]
	stp x23, x30, [sp, 32]

	// Passed parameters - x0 : *_JNIEnv, x1 : thisObject

	mov x19, x0   // x19 <- Backup of *JNIEnv as we'll use it very often
	mov x20, x1   // x20 <- Backup of thisObject as we'll invoke methods on it
	ldr x21, [x0] // x21 <- Backup of *_JNINativeInterface, located at *_JNIEnv,
	              //      since we'll also use it a lot

	/* Preparing to call NewString(*_JNIEnv : x0, 
	                     *string_characters : x1, 
	                          string_length : x2).
	   *_JNIEnv is still in x0.
	*/

	adr x1, secret       // x1 <- *secret : The UTF16-LE characters composing 
	                     //                 the java.lang.String we'll pass to
	                     //                 the Java method called afterwards.
	mov x2, #secret_len  // x2 <- secret_len : The length of that java.lang.String
	ldr x3, [x21, #1304] // x3 <- *JNINativeInterface->NewString function. 
	                     // +1304 is NewString's offset in the JNINativeInterface
	                     // structure.
	blr x3               // secret_java_string : x0 <- NewString(*_JNIEnv : x0, 
	                     //                                       *secret : x1,
	                     //                                    secret_len : x2)

	mov x22, x0          // x22 <- secret_java_string
	                     // Keep the returned string for later use

	/* Calling showText(java.lang.String) through the JNI
	
	   First : We need the class of thisObject. We could pass it directly
	   to the procedure but, for learning purposes, we'll use JNI methods
	   to get it.
	*/

	// Preparing to call GetObjectClass(*_JNIEnv : x0, thisObject : x1)
	mov x0, x19         // x0 <- *_JNIEnv (previously saved in x19)
	mov x1, x20         // x1 <- thisObject (previously saved in x20)
	ldr x2, [x21, #248] // x2 <- Get *JNINativeInterface->GetObjectClass (*JNINativeInterface+248)
	blr x2              // jclass : x0 <- GetObjectClass(*JNIEnv : x0, 
	                    //                            thisObject : x1)
	/* Second : We need the JNI ID of the method we want to call
	   Preparing for GetMethodId(*JNIEnv : x0, 
	                              jclass : x1, 
	                         method_name : x2, 
	                    method_signature : x3)
	*/

	mov x1, x0  // x1 <- jclass returned by GetObjectClass
	mov x0, x19 // x0 <- *JNIEnv, previously backed up in x19
	adr x2, java_method_name      // x2 <- &java_method_name : The method name
	adr x3, java_method_signature // x3 <- &java_method_signature : The method signature
	ldr x4, [x21, #264]           // Get *JNINativeInterface->GetMethodId

	blr x4     // revealTheSecretID : x0 <- GetMethodId(*_JNIEnv : x0, 
	           //                                         jclass : x1, 
	           //                                   &method_name : x2, 
	           //                              &method_signature : x3)

	// Finally : Call the method. Since it's a method returning void, 
	// we'll use CallVoidMethod.
	// Preparing to call CallVoidMethod(*_JNIEnv : x0, 
	//                                thisObject : x1,
	//                         revealTheSecretID : x2,
	//                             secret_string : x3)

	mov x2, x0          // x2 <- revealTheSecretID
	mov x1, x20         // x1 <- thisObject (previously saved in x20)
	mov x0, x19         // x0 <- *_JNIEnv (previously saved in x19)
	mov x3, x22         // x3 <- secret_java_string (previously saved in x22)
	ldr x4, [x21, #488] // x4 <- *_JNINativeInterface->CallVoidMethod (+488).
	blr x4 // CallVoidMethod(*_JNIEnv : x0, 
	       //              thisObject : x1,
	       //       revealTheSecretID : x2,
	       //              the_string : x3)
	       // => Java : revealTheSecret(the_string)

	ldp x19, x20, [sp]
	ldp x21, x22, [sp, 16]
	ldp x23, x30, [sp, 32]
	add sp, sp, 48
	ret
